var app = new Vue({
	el: '#app',
	data: {
		ui: {
			nav: 'home',
		},
		tabs: [],
		currentTabIndex: 0,
		text: "before",
		directory: [],
	},
	created() {
		ajaxGet('/directory?D:\\', data => {
			this.directory = JSON.parse(data);
		});
	},
	mounted() {
		document.onkeydown = (e) => {
			e = e || window.event;
			if(e.ctrlKey) {
				var c = e.which || e.keyCode;
				switch(c) {
					case 83://Block Ctrl+S
						e.preventDefault();     
						e.stopPropagation();
						this.save();
					break;
				}
			}
		};
	},
	beforeDestroy() {
	},
	watch: {
		"directory.basePath": function (newBasePath, oldBasePath) {
			ajaxGet('/directory?'+this.directory.basePath, data => {
				this.directory = JSON.parse(data);
			});
		}
	},
	methods: {
		extension: function(path) {
			return path.split('.').pop();
		},
		iconForExtension: function(ext) {
			if(this.extension(ext) == 'pug')
				return "vscode-icons/file_type_pug.svg";
			if(this.extension(ext) == 'styl')
				return "vscode-icons/file_type_stylus.svg";
			if(this.extension(ext) == 'd')
				return "vscode-icons/file_type_dlang.svg";
			if(this.extension(ext) == 'js')
				return "vscode-icons/file_type_js.svg";
			if(this.extension(ext) == 'html')
				return "vscode-icons/file_type_html.svg";
			if(this.extension(ext) == 'css')
				return "vscode-icons/file_type_css.svg";
			if(this.extension(ext) == 'json')
				return "vscode-icons/file_type_json.svg";
			if(this.extension(ext) == 'md')
				return "vscode-icons/file_type_markdown.svg";
			else 
				return "vscode-icons/default_file.svg";
		},
		test: function() {
			this.text = "after";
		},
		closeTab: function(i) {
			console.log("closeTab:", i, "-", this.currentTabIndex);
			if(this.currentTabIndex == i) {
				this.currentTabIndex = i - 1;
			}
			this.tabs.splice(i, 1);
		},
		indexOfTab: function(e) {
			let xxx = this.directory.basePath+e.name;
			return this.tabs.findIndex(t=>t.path==xxx);
		},
		open: function(e) {
			if(e.isDirectory) {
				console.log("openFolder: ", e.name);
				this.directory.basePath = this.directory.basePath + e.name;
			}
			else {
				let idx = this.indexOfTab(e);
				if(idx >= 0) {
					console.log("already open: ", idx);
					this.currentTabIndex = idx;
					return;
				}

				ajaxGet('/file?'+this.directory.basePath+e.name, data => {
					let j = JSON.parse(data);
					this.tabs.push({
						title: j.title,
						path: j.path,
						code: j.code,
					});
					this.currentTabIndex = this.tabs.length - 1;
				});
			}
		},
		dirUp: function() {
			ajaxGet('/directory?'+this.directory.basePath+'..\\', data => {
				this.directory = JSON.parse(data);
			});
		},
		save: function() {
			if(this.currentTabIndex < this.tabs.length) {
				console.log("save: ", this.tabs[this.currentTabIndex].path);
				ajaxPost('/file', JSON.stringify({
					path: this.tabs[this.currentTabIndex].path,
					code: this.tabs[this.currentTabIndex].code,
				}), ()=>{}, ()=>{});
			}
		}
	}
});