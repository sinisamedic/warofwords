import { Client } from './godot-mcp/server/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.js';
import { StdioClientTransport } from './godot-mcp/server/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.js';
import { spawn } from 'node:child_process';
import { mkdirSync, openSync, writeFileSync, readFileSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const machinePath = resolve(root, '.local/machine.json');
const machine = existsSync(machinePath) ? JSON.parse(readFileSync(machinePath, 'utf8')) : {};
const godotExecutable = process.env.GODOT_EXECUTABLE || machine.godotExecutable;
if (!godotExecutable || !existsSync(godotExecutable)) {
  throw new Error('Set GODOT_EXECUTABLE or .local/machine.json godotExecutable to your Godot executable. See docs/setup.md.');
}
if (process.argv.includes('--check-config')) {
  console.log('Godot executable and MCP client dependencies found. No editor launched.');
  process.exit(0);
}
mkdirSync(resolve(root, '.local'), { recursive: true });
mkdirSync(resolve(root, 'setup-probe/probe_runs'), { recursive: true });
const scenePath = `res://probe_runs/connection_${Date.now()}.tscn`;
const log = openSync(resolve(root, '.local/godot-editor.log'), 'w');
const transport = new StdioClientTransport({
  command: process.execPath,
  args: [resolve(root, 'tools/godot-mcp/server/build/index.js')],
  stderr: 'inherit',
});
const client = new Client({ name: 'godot-setup-verification', version: '1.0.0' });
const results = [];
async function call(name, args = {}) {
  const result = await client.callTool({ name, arguments: args });
  const item = result.content?.find(x => x.type === 'text');
  const data = item ? JSON.parse(item.text) : result;
  if (result.isError || data.error || data.success === false) throw new Error(JSON.stringify(data));
  results.push({ name, data });
  console.log(name + ': OK');
  return data;
}
try {
  await client.connect(transport);
  if (!process.argv.includes('--connect-existing')) {
  const editor = spawn(godotExecutable,
    ['--editor', '--path', resolve(root, 'setup-probe'), '--log-file', resolve(root, '.local/godot-engine.log')],
    { detached: true, windowsHide: true, stdio: ['ignore', log, log] });
  editor.unref();
  writeFileSync(resolve(root, '.local/godot-editor.pid'), String(editor.pid));
  }
  let connected = false;
  for (let attempt = 0; attempt < 40; attempt++) {
    try { await call('get_project_info'); connected = true; break; }
    catch { await new Promise(r => setTimeout(r, 1000)); }
  }
  if (!connected) throw new Error('Editor did not connect within 40 seconds');
  await call('create_scene', { scene_path: scenePath, root_type: 'Control' });
  await new Promise(r => setTimeout(r, 800));
  await call('add_node', { type: 'Label', name: 'ConnectionStatus', properties: {
    text: 'Provera veze', position: 'Vector2(32, 100)', size: 'Vector2(416, 160)', horizontal_alignment: '1'
  }});
  await call('update_property', { node_path: 'ConnectionStatus', property: 'text', value: 'Godot MCP radi!\nProbna scena je napravljena\ni izmenjena preko MCP veze.' });
  await call('set_theme_font_size', { node_path: 'ConnectionStatus', name: 'font_size', size: 22 });
  await call('save_scene');
  await call('get_scene_tree');
  await call('play_scene', { mode: 'current' });
  await new Promise(r => setTimeout(r, 4000));
  await call('get_game_scene_tree');
  const shot = await call('get_game_screenshot');
  writeFileSync(resolve(root, '.local/godot-mcp-probe.png'), Buffer.from(shot.base64, 'base64'));
  delete shot.base64;
  await call('get_editor_errors');
  await call('stop_scene');
  writeFileSync(resolve(root, '.local/godot-mcp-verification.json'), JSON.stringify(results, null, 2));
  console.log('Verification report saved. Editor remains open.');
} finally {
  await client.close();
}
