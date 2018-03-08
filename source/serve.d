module serve;
import vibe.vibe;

private void serveFile_impl(string path, string mimetype)(HTTPServerRequest req, HTTPServerResponse res) {
	import std.path;
	string[string] mimetypeMapping = [
		`.ico`: `image/x-icon`,
		`.html`: `text/html; charset=utf-8`,
		`.css`: `text/css; charset=utf-8`,
		`.js`: `text/javascript`,
		`.eot`: `application/vnd.ms-fontobject`,
		`.svg`: `image/svg+xml`,
		`.ttf`: `application/font-ttf`,
		`.woff`: `application/font-woff`,
		`.woff2`: `application/font-woff2`,
		`.otf`: `application/font-otf`,
	];

	version(serve_static_files) {
		res.writeBody(import(path), 200, mimetype.length > 0 ? mimetype : mimetypeMapping[path.extension]);
	}
	else{
		import std.algorithm;
		import std.process;
		import std.file;
		if(path.endsWith(`.html`)) {
			mkdirRecurse(`views/html/`);
			auto pug = `pug --pretty views/pug/ --out views/html/`.executeShell(null, Config.suppressConsole);
			if (pug.status != 0) {
				logFatal(pug.output);
				throw new Exception("pug failed");
			}
		}
		if(path.endsWith(`.css`)) {
			mkdirRecurse(`views/css/`);
			auto stylus = `stylus views/styl/ -o views/css/`.executeShell(null, Config.suppressConsole);
			if (stylus.status != 0) {
				logFatal(stylus.output);
				throw new Exception("stylus failed");
			}
		}
		res.writeBody(readFile(`views/` ~ path), 200, mimetype.length > 0 ? mimetype : mimetypeMapping[path.extension]);
	}
}

enum serveFile(string path, string mimetype = "") = &serveFile_impl!(path, mimetype);
