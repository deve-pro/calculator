#!/usr/bin/env python3
"""Add the Supabase OAuth callback intent filter to generated Android scaffolding."""

from pathlib import Path
import xml.etree.ElementTree as ET

manifest = Path("android/app/src/main/AndroidManifest.xml")
android_ns = "http://schemas.android.com/apk/res/android"
ET.register_namespace("android", android_ns)
root = ET.parse(manifest).getroot()
name = f"{{{android_ns}}}name"

for activity in root.findall(".//activity"):
    if activity.get(name, "").endswith("MainActivity"):
        for intent_filter in activity.findall("intent-filter"):
            data = intent_filter.find("data")
            if data is not None and data.get(f"{{{android_ns}}}scheme") == "io.supabase.calculator":
                break
        else:
            intent_filter = ET.SubElement(activity, "intent-filter")
            ET.SubElement(intent_filter, "action", {name: "android.intent.action.VIEW"})
            ET.SubElement(intent_filter, "category", {name: "android.intent.category.DEFAULT"})
            ET.SubElement(intent_filter, "category", {name: "android.intent.category.BROWSABLE"})
            ET.SubElement(
                intent_filter,
                "data",
                {f"{{{android_ns}}}scheme": "io.supabase.calculator", f"{{{android_ns}}}host": "login-callback"},
            )
        ET.indent(root, space="    ")
        ET.ElementTree(root).write(manifest, encoding="utf-8", xml_declaration=True)
        break
else:
    raise SystemExit("Could not find the generated MainActivity in AndroidManifest.xml")
