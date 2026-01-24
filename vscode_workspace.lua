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

	-- workspace should be first for clangd to use it as the working directory
	p.w('{')
	p.w('"path": "."')
	p.w('},')

	--
	-- Project list
	--
	local tr = workspace.grouptree(wks)
	tree.traverse(tr, {
		onleaf = function(n)
			local prj = n.project

			if prj.workspace.location ~= prj.location then
				local prjpath = path.getrelative(prj.workspace.location, prj.location)
				p.w('{')
				p.w('"path": "%s"', prjpath)
				p.w('},')
			end

			-- add root source file directories
			local root_src_dirs = {}
			local non_root_path = '' -- used to remove the non root part from the end of a leaf node's path
			local tr = project.getsourcetree(prj)
			tree.traverse(tr, {
				onbranchenter = function(node, depth)
					if depth ~= 0 then
						non_root_path = non_root_path .. '/' .. node.name
					end
				end,
				onbranchexit = function(node, depth)
					if depth ~= 0 then
						non_root_path = non_root_path:sub(1, non_root_path:len()-(node.name:len()+1))
					end
				end,
				onleaf = function(node, depth)
					if node.relpath == nil then
						return
					end
					non_root_path = non_root_path ..'/'.. node.name
					local rel_root_path = node.relpath:sub(1, node.relpath:len()-(non_root_path:len()))
					non_root_path = non_root_path:sub(1, non_root_path:len()-(node.name:len()+1))
					print(rel_root_path)
					root_src_dirs[rel_root_path] = true
				end
			})

			for src_dir_rel in pairs(root_src_dirs) do
				print(src_dir_rel)
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
