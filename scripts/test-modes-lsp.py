#!/usr/bin/env python3
"""Small deterministic stdio LSP peer, not a real Python/Go language server."""
import json
import sys


def send(message):
    body = json.dumps({"jsonrpc": "2.0", **message}).encode("utf-8")
    sys.stdout.buffer.write(f"Content-Length: {len(body)}\r\n\r\n".encode("ascii") + body)
    sys.stdout.buffer.flush()


def main():
    documents = {}
    name = sys.argv[1]
    while True:
        headers = {}
        while True:
            line = sys.stdin.buffer.readline()
            if not line:
                return
            if line == b"\r\n":
                break
            key, value = line.decode("ascii").split(":", 1)
            headers[key.lower()] = value.strip()
        message = json.loads(sys.stdin.buffer.read(int(headers["content-length"])))
        method = message.get("method")
        params = message.get("params", {})
        result = None
        if method == "initialize":
            result = {
                "capabilities": {
                    "textDocumentSync": 1,
                    "documentFormattingProvider": True,
                    "completionProvider": {"triggerCharacters": ["."]},
                },
                "serverInfo": {"name": "fixture-" + name},
            }
        elif method == "textDocument/didOpen":
            document = params["textDocument"]
            documents[document["uri"]] = document["languageId"]
            send({"method": "textDocument/publishDiagnostics", "params": {
                "uri": document["uri"],
                "diagnostics": [{
                    "range": {"start": {"line": 0, "character": 0},
                              "end": {"line": 0, "character": 1}},
                    "severity": 2, "source": name,
                    "message": "fixture diagnostic for " + document["languageId"],
                }],
            }})
        elif method == "textDocument/completion":
            result = [{"label": "fixture_completion", "kind": 6}]
        elif method == "textDocument/formatting":
            language = documents[params["textDocument"]["uri"]]
            result = [{"range": {"start": {"line": 0, "character": 0},
                                 "end": {"line": 0, "character": 0}},
                       "newText": ("# " if language == "python" else "// ")
                                  + "fixture formatted\n"}]
        elif method == "exit":
            return
        if "id" in message:
            send({"id": message["id"], "result": result})


if __name__ == "__main__":
    main()
