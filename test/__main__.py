import os
import sys
import json
sys.path.append(os.path.abspath('./build'))

import dprint_python_bridge

FILE = os.path.abspath("./test/node_modules.js")

with open(FILE, 'r') as file:
    code = file.read()
    res = dprint_python_bridge.format_text(FILE, code, json.dumps({"indentWidth": 2, "lineWidth": 120}))
    print("Output size: %s" % len(res))
