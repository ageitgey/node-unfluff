/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import path from 'path';
import util from 'util';
import fs from 'fs';
import deepEqual from 'deep-equal';
import object from 'assert';
for (let name in object) { const func = object[name]; global[name] = func; }

// See http://wiki.ecmascript.org/doku.php?id=harmony:egal
const egal = function(a, b) {
  if (a === b) {
    return (a !== 0) || ((1/a) === (1/b));
  } else {
    return (a !== a) && (b !== b);
  }
};

// A recursive functional equivalence helper; uses egal for testing equivalence.
var arrayEgal = function(a, b) {
  if (egal(a, b)) { return true;
  } else if ((Array.isArray(a)) && Array.isArray(b)) {
    if (a.length !== b.length) { return false; }
    for (let idx = 0; idx < a.length; idx++) { const el = a[idx]; if (!arrayEgal(el, b[idx])) { return false; } }
    return true;
  }
};

global.inspect = o => util.inspect(o, false, 2, true);
global.eq      = (a, b, msg) => ok(egal(a, b), msg != null ? msg : `${inspect(a)} === ${inspect(b)}`);
global.arrayEq = (a, b, msg) => ok(arrayEgal(a, b), msg != null ? msg : `${inspect(a)} === ${inspect(b)}`);
global.deepEq  = (a, b, msg) => ok(deepEqual(a, b), msg != null ? msg : `${inspect(a)} === ${inspect(b)}`);

global.fs = fs;

const object1 = require('./');
for (let k of Object.keys(object1 || {})) { const v = object1[k]; global[k] = v; }
