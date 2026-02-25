import json

with open("phpstan-output.json", "r") as f:
    data = json.load(f)

for file_path, file_data in data.get("files", {}).items():
    for msg in file_data.get("messages", []):
        m = msg["message"]
        if "Regex pattern is invalid" in m or "TYPE_NUMERIC" in m or "static()" in m or "registerTaskType(" in m or "header" in m or "assignToChangedRecords" in m:
            print(f"{file_path}:{msg['line']} - {m}")
