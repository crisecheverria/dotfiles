-- Helper function to detect Java version from project
local function detect_project_java_version()
	local pom_path = vim.fn.findfile("pom.xml", ".;")
	local build_gradle = vim.fn.findfile("build.gradle", ".;") or vim.fn.findfile("build.gradle.kts", ".;")

	-- Try to detect Java version from pom.xml
	if pom_path ~= "" then
		local pom_content = vim.fn.readfile(pom_path)
		for _, line in ipairs(pom_content) do
			local version = line:match("<java%.version>(%d+)</java%.version>")
			if version then
				return tonumber(version)
			end
		end
	end

	-- Try to detect from Gradle
	if build_gradle ~= "" then
		local gradle_content = vim.fn.readfile(build_gradle)
		for _, line in ipairs(gradle_content) do
			local version = line:match("sourceCompatibility.*[\"']?(%d+)")
			if version then
				return tonumber(version)
			end
		end
	end

	-- Default to system Java version (21)
	return 21
end

-- Helper function to get Java home for specific version
local function get_java_home(version)
	local java_home = vim.fn.system("/usr/libexec/java_home -v " .. version .. " 2>/dev/null"):gsub("\n", "")

	-- Fallback to default if specific version not found
	if vim.v.shell_error ~= 0 or java_home == "" then
		vim.notify("Java " .. version .. " not found, falling back to Java 21", vim.log.levels.WARN)
		java_home = vim.fn.system("/usr/libexec/java_home -v 21"):gsub("\n", "")
	end

	return java_home
end

-- Lazy load Java plugins only when opening Java files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function()
		-- Install dependencies first
		vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })
		vim.pack.add({ "https://github.com/nvim-neotest/nvim-nio" })
		vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })
		vim.pack.add({ "https://github.com/nvim-java/lua-async-await" })

		-- Install nvim-java and its components
		vim.pack.add({ "https://github.com/nvim-java/nvim-java-core" })
		vim.pack.add({ "https://github.com/nvim-java/nvim-java-test" })
		vim.pack.add({ "https://github.com/nvim-java/nvim-java-dap" })
		vim.pack.add({ "https://github.com/nvim-java/nvim-java-refactor" })
		vim.pack.add({ "https://github.com/nvim-java/nvim-java" })

		-- Detect and configure Java version dynamically
		local project_java_version = detect_project_java_version()
		local java_home = get_java_home(project_java_version)
		vim.env.JAVA_HOME = java_home

		vim.notify("Using Java " .. project_java_version .. " from: " .. java_home, vim.log.levels.INFO)

		require("java").setup({
			-- Enable Spring Boot features
			java_test = {
				enable = true,
			},
			java_debug_adapter = {
				enable = true,
			},
			jdk = {
				auto_install = false,
			},
			notifications = {
				dap = true,
			},
			-- Enhanced root markers for Spring Boot
			root_markers = {
				"settings.gradle",
				"settings.gradle.kts",
				"pom.xml",
				"build.gradle",
				"mvnw",
				"gradlew",
				"build.gradle.kts",
				"application.properties",
				"application.yml",
				"application.yaml",
			},
			-- Spring Boot specific jdtls settings
			jdtls = {
				settings = {
					java = {
						configuration = {
							runtimes = {
								{
									name = "JavaSE-" .. project_java_version,
									path = java_home,
									default = true,
								},
								-- Backup Java 21 runtime
								{
									name = "JavaSE-21",
									path = get_java_home(21),
									default = false,
								},
							},
						},
						-- Spring Boot optimizations
						compile = {
							nullAnalysis = {
								mode = "automatic",
							},
						},
						completion = {
							favoriteStaticMembers = {
								"org.assertj.core.api.Assertions.*",
								"org.junit.jupiter.api.Assertions.*",
								"org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
								"org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
							},
							importOrder = {
								"java",
								"javax",
								"com",
								"org",
							},
						},
						-- Enable Spring Boot features
						references = {
							includeDecompiledSources = true,
						},
						format = {
							enabled = true,
						},
						-- Maven/Gradle settings
						maven = {
							downloadSources = true,
							downloadJavadoc = true,
						},
						gradle = {
							downloadSources = true,
							downloadJavadoc = true,
						},
						-- Code generation
						codeGeneration = {
							toString = {
								template = "${object.className}{${member.name}=${member.value}, ${otherMembers}}",
							},
							useBlocks = true,
						},
					},
				},
			},
		})

		-- Remove the conflicting lspconfig.jdtls.setup() call
		-- nvim-java handles jdtls configuration completely
	end,
	once = true, -- Only run this once
})
