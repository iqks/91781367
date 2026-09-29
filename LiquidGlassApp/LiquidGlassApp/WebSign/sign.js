// 签名助手 - 内置签名引擎 (zsign-wasm)
// 全局 API: window.signIpaStart(ipaB64, p12B64, provB64, password)
// 完成后通过 window.webkit.messageHandlers.signResult.postMessage({status, payload}) 回调

var signModule = null;
var signBusy = false;

function setStatus(text) {
  var el = document.getElementById('status');
  if (el) el.textContent = text;
  // 同时把进度通过消息通道上报，Swift 侧实时显示（JavaScriptCore 环境下同样有效）
  try {
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.signResult) {
      window.webkit.messageHandlers.signResult.postMessage({ status: 'log', payload: text });
    }
  } catch (e) {}
}

function b64ToU8(b64) {
  var bin = atob(b64);
  var out = new Uint8Array(bin.length);
  for (var i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

function u8ToB64(u8) {
  var bin = '';
  var CHUNK = 0x8000;
  for (var i = 0; i < u8.length; i += CHUNK) {
    bin += String.fromCharCode.apply(null, u8.subarray(i, i + CHUNK));
  }
  return btoa(bin);
}

function postResult(status, payload) {
  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.signResult) {
    try {
      window.webkit.messageHandlers.signResult.postMessage({ status: status, payload: payload || '' });
    } catch (e) {
      // 消息体过大时通知失败，让 Swift 侧处理
      window.webkit.messageHandlers.signResult.postMessage({ status: 'error', payload: 'result too large: ' + e });
    }
  }
}

async function ensureModule() {
  if (signModule) return signModule;
  setStatus('正在加载签名核心…');
  // 使用 Swift 注入的 base64 数据（WKWebView 内 fetch 相对路径不可用）
  if (!window.ZSIGN_WASM_B64) throw new Error('签名核心数据缺失');
  var wasmBinary = b64ToU8(window.ZSIGN_WASM_B64);
  signModule = await createZsignModule({ wasmBinary: wasmBinary });
  return signModule;
}

async function signIpaStart(ipaB64, p12B64, provB64, password) {
  if (signBusy) {
    postResult('error', '签名任务正在进行中');
    return;
  }
  signBusy = true;
  try {
    setStatus('正在解压 IPA…');
    var ipaBytes = b64ToU8(ipaB64);
    var zip = await JSZip.loadAsync(ipaBytes);

    var mod = await ensureModule();
    setStatus('正在写入文件…');

    var root = '/zsign_in_' + Date.now();
    mod.FS.mkdirTree(root + '/input');
    mod.FS.mkdirTree(root + '/assets');

    var keys = Object.keys(zip.files);
    for (var i = 0; i < keys.length; i++) {
      var entry = zip.files[keys[i]];
      var clean = keys[i].replace(/\\/g, '/').replace(/^\/+/, '');
      if (!clean) continue;
      var outPath = root + '/input/' + clean;
      if (entry.dir) {
        mod.FS.mkdirTree(outPath);
        continue;
      }
      var data = await entry.async('uint8array');
      var idx = outPath.lastIndexOf('/');
      if (idx > 0) mod.FS.mkdirTree(outPath.slice(0, idx));
      mod.FS.writeFile(outPath, data, { canOwn: true });
    }

    var certPath = root + '/assets/cert.p12';
    var provPath = root + '/assets/prov.mobileprovision';
    mod.FS.writeFile(certPath, b64ToU8(p12B64), { canOwn: true });
    mod.FS.writeFile(provPath, b64ToU8(provB64), { canOwn: true });

    setStatus('正在签名（可能需要十几秒）…');
    var signBundle = mod.cwrap('zsign_sign_bundle', 'number', [
      'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string',
      'number', 'number', 'number', 'number', 'number'
    ]);

    var ret = signBundle(
      root + '/input',          // inputFolder
      '',                        // certFile（P12 内含证书）
      certPath,                  // pkeyFile（P12）
      provPath,                  // provFile
      password || '',            // password
      '',                        // entitlementsFile
      '',                        // bundleId
      '',                        // bundleVersion
      '',                        // displayName
      0,                         // adhoc
      0,                         // sha256Only（双哈希更兼容）
      1,                         // forceSign
      0,                         // weakInject
      0                          // enableCache
    );

    if (ret !== 0) {
      throw new Error('签名失败 (错误码 ' + ret + ')');
    }

    setStatus('正在重新打包…');
    var outZip = new JSZip();
    (function walk(p) {
      var list = mod.FS.readdir(p);
      for (var j = 0; j < list.length; j++) {
        var n = list[j];
        if (n === '.' || n === '..') continue;
        var ap = p + '/' + n;
        var st = mod.FS.stat(ap);
        if (mod.FS.isDir(st.mode)) {
          walk(ap);
        } else {
          var rel = ap.slice((root + '/input').length + 1);
          outZip.file(rel, mod.FS.readFile(ap, { encoding: 'binary' }));
        }
      }
    })(root + '/input');

    var outBytes = await outZip.generateAsync({
      type: 'uint8array',
      compression: 'DEFLATE',
      compressionOptions: { level: 9 }
    });

    setStatus('签名完成，正在返回…');
    postResult('success', u8ToB64(outBytes));
  } catch (e) {
    setStatus('签名失败');
    postResult('error', String(e && e.message ? e.message : e));
  } finally {
    signBusy = false;
  }
}
