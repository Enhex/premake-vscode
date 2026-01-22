--
-- Name:        vscode_workspace.lua
-- Purpose:     Generate a vscode file.
-- Author:      Ryan Pusztai
-- Modified by: Andrea Zanellato
--              Manu Evans
--              Yehonatan Ballas
-- Created:     2013/05/06
-- Copyright:   (c) 2008-2020 Jason Perkins and the Premake project
--

local p = premake
local project = p.project
local workspace = p.workspace
local tree = p.tree
local vscode = p.modules.vscode

vscode.workspace = {}
local m = vscode.workspace

--
-- Generate a vscode file
--
function m.generate(wks)
	p.utf8()
	p.w('{"folders": [')

	--
	-- Project list
	--
	local tr = workspace.grouptree(wks)
	tree.traverse(tr, {
		onleaf = function(n)
			local prj = n.project

			local prjpath = path.getrelative(prj.workspace.location, prj.location)
 			p.w('{')
			p.w('"path": "%s"', prjpath)
 			p.w('},')

			-- add root source file directories
			local root_src_dirs = {}
			local tr = project.getsourcetree(prj)
			tree.traverse(tr, {
				onleaf = function(node, depth)
					if depth ~= 0 or node.abspath == nil then
						return
					end
					root_src_dirs[path.getdirectory(node.abspath)] = true
				end
			})

			for src_dir in pairs(root_src_dirs) do
				local src_dir_rel = path.getrelative(prj.workspace.location, src_dir)
				p.w('{')
				p.w('"path": "%s"', src_dir_rel)
				p.w('},')
			end
		end,
	})

	-- for clangd to find compile_commands.json in the build dir
	p.w('],')
	p.w('"settings":{')
	p.w('"clangd.arguments":[')
	p.w('"--compile-commands-dir=."')
	p.w(']}')

	p.w('}')

	--TODO wks.startproject
end
