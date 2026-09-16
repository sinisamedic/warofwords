// DOM stand-in smoke test: execute the unmodified entry script, including startup.
// This checks boot/navigation and global isolation, not browser layout or pointer events.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync(path.join(__dirname, '..', 'app.js'), 'utf8');
function boot(hash = '') {
  const handlers = {};
  const element = {
    innerHTML: '', style: {}, classList: { toggle() {} },
    querySelector() { return element; }, querySelectorAll() { return []; },
    getBoundingClientRect() { return { x: 0, y: 0, width: 350, height: 200 }; },
    setAttribute() {}, append() {}, remove() {}, focus() {},
    addEventListener(type, fn) { handlers[type] = fn; }
  };
  const rootElement = { ...element };
  const globalTop = {};
  const context = {
    document: { querySelector: selector => selector === '#game' ? rootElement : element, querySelectorAll: () => [], addEventListener() {}, createElement: () => element },
    window: { addEventListener() {}, innerWidth: 844, innerHeight: 390 },
    history: { replaceState() {} }, location: { hash },
    setInterval() { return 1; }, clearInterval() {}, setTimeout() { return 1; }, clearTimeout() {}
  };
  Object.defineProperty(context, 'top', { value: globalTop, writable: false, configurable: false });
  vm.runInNewContext(source, context);
  assert.equal(context.top, globalTop);
  assert.equal(context.navigate, undefined, 'private functions must not leak onto Window');
  assert.equal(context.screenHeader, undefined);
  return { element: rootElement, click(dataset) { handlers.click({ target: { closest: () => ({ dataset }) } }); } };
}
const app = boot();
assert.match(app.element.innerHTML, /WAR OF/);
assert.match(app.element.innerHTML, /PLAY/);
for (const [id, text] of [['map','Campaign'], ['armory','Your arsenal'], ['powers','Choose a power-up'], ['workshop','Workshop'], ['home','WAR OF']]) {
  app.click({ go: id });
  assert.ok(app.element.innerHTML.includes(text), `${id} must render`);
}
const battle = boot('#battle');
assert.equal((battle.element.innerHTML.match(/data-tile=/g) || []).length, 28);
assert.match(battle.element.innerHTML, /SENTINEL/);
console.log('PASS: full entry script boots, all six screens render markup, and browser globals remain untouched.');
