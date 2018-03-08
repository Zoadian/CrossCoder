import vibe.vibe;
import serve;

void main() {
	auto settings = new HTTPServerSettings;
	settings.sessionStore = new MemorySessionStore;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.useCompressionIfPossible = true;
	settings.options |= HTTPServerOption.parseJsonBody;

	auto router = new URLRouter;
	router.get("/",             serveFile!(`html/app.html`));
	router.get("/favicon.ico",  serveFile!(`icon/favicon.ico`));
	router.get("/css/app.css",  serveFile!(`css/app.css`));
	router.get("/js/app.js",    serveFile!(`js/app.js`));
	router.get("/js/ajax.js",    serveFile!(`js/ajax.js`));
	router.get("/js/vue.js",    serveFile!(`js/vue.js`));
	router.get("/js/vue_db.js", serveFile!(`js/vue_db.js`));
	router.get("/fonts/fontawesome-webfont.eot",   serveFile!(`font/fontawesome-webfont.eot`));
	router.get("/fonts/fontawesome-webfont.svg",   serveFile!(`font/fontawesome-webfont.svg`));
	router.get("/fonts/fontawesome-webfont.ttf",   serveFile!(`font/fontawesome-webfont.ttf`));
	router.get("/fonts/fontawesome-webfont.woff",  serveFile!(`font/fontawesome-webfont.woff`));
	router.get("/fonts/fontawesome-webfont.woff2", serveFile!(`font/fontawesome-webfont.woff2`));
	router.get("/fonts/FontAwesome.otf",           serveFile!(`font/FontAwesome.otf`));

	router.get("/directory", &getDirectoryContent);
	router.get("/file", &getFileContent);
	router.post("/file", &setFileContent);

	router.get("*", serveStaticFiles("public/"));

	listenHTTP(settings, router);
	runApplication();
}

void getDirectoryContent(HTTPServerRequest req, HTTPServerResponse res) {
	import vibe.core.path;
	auto path = WindowsPath(req.queryString.urlDecode);
	path.normalize();
	// if(!path.hasParentPath) {
	// 	path = getWorkingDirectory();
	// }

	auto response = Json([
		"basePath": Json(path.toString),
		"entries": {
			auto entries = Json.emptyArray;
			foreach(d; iterateDirectory(path)) {
				entries ~= Json([
					"name": Json(d.name ~ (d.isDirectory ? "\\" : "")),
					"isDirectory": Json(d.isDirectory),
				]);
			}
			return entries;
		}(),
	]);
	res.writeBody(response.serializeToJsonString(), 200);
}

void getFileContent(HTTPServerRequest req, HTTPServerResponse res) {
	auto path = WindowsPath(req.queryString.urlDecode);
	path.normalize();
	auto content = readFileUTF8(path);
	auto response = Json([
		"title": Json(path.head.name),
		"path": Json(path.toString),
		"code": Json(content),
	]);
	res.writeBody(response.serializeToJsonString(), 200);
}

void setFileContent(HTTPServerRequest req, HTTPServerResponse res) {
	logInfo(req.json.to!string);
	auto path = WindowsPath(req.json["path"].to!string);
	auto code = req.json["code"].to!string;

	try {
		writeFileUTF8(path, code);
	}
	catch(Exception e) {
		logInfo(e.to!string);
		throw e;
	}	

	res.writeBody(Json.emptyObject.serializeToJsonString(), 200);
}