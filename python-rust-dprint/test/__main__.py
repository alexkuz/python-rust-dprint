import os
import sys
import json
import time

import dprint_python_bridge

FILE = os.path.abspath("./test/node_modules.js")

with open(FILE, 'r') as file:
    code = file.read()
    print("Input size: %s" % len(code))
    start_time = time.time()
    res = dprint_python_bridge.format_text(FILE, code, json.dumps({"indentWidth": 2, "lineWidth": 120}))
    end_time = time.time()
    print("Output size: %s" % len(res))
    print('\n\x1b[0;33m' + '\n'.join(res.split('\n')[:10]) + '\n...\n\x1b[0m')
    print('Processed in {:.2f}s'.format(end_time - start_time))
