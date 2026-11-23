"""Add network access to generated Android scaffolding for the install counter."""

from pathlib import Path
import xml.etree.ElementTree as ET

manifest = Path("android/app/src/main/AndroidManifest.xml")
android_ns = "http://schemas.android.com/apk/res/android"
ET.register_namespace("android", android_ns)
root = ET.parse(manifest).getroot()
name = f"{{{android_ns}}}name"

internet_permission = "android.permission.INTERNET"
application = root.find("application")
if application is None:
    raise SystemExit("Could not find the generated Android application element")

changed = False
if not any(permission.get(name) == internet_permission for permission in root.findall("uses-permission")):
    insert_at = list(root).index(application)
    root.insert(insert_at, ET.Element("uses-permission", {name: internet_permission}))
    changed = True

# Avoid restoring this install's local account ID onto another Android device.
allow_backup = f"{{{android_ns}}}allowBackup"
if application.get(allow_backup) != "false":
    application.set(allow_backup, "false")
    changed = True

if changed:
    ET.indent(root, space="    ")
    ET.ElementTree(root).write(manifest, encoding="utf-8", xml_declaration=True)
