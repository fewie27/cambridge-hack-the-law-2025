import subprocess
import os
import sys

# Einstellungen
openapi_file = "api.yml"
output_dir = "../frontend/counterclaimer/lib/api"
generator_name = "dart-dio"  # oder "dart" für http-basierten Client
package_name = "my_flutter_api_client"

# Optional: zusätzliche Generator-Konfiguration
additional_properties = {
    "pubName": package_name,
    "pubAuthor": "Your Name",
    "pubVersion": "1.0.0",
    "useEnumExtension": True,
    "nullableFields": True,
    "browserClient": False,
    "supportNullSafety": True
}

def ensure_openapi_generator_installed():
    try:
        subprocess.run(["openapi-generator", "version"], check=True, stdout=subprocess.PIPE)
    except Exception:
        print("OpenAPI Generator CLI nicht gefunden. Versuche Installation via Homebrew (macOS/Linux) oder npm (plattforübergreifend)...")
        if sys.platform.startswith("linux") or sys.platform == "darwin":
            subprocess.run(["brew", "install", "openapi-generator"], check=True)
        else:
            subprocess.run(["npm", "install", "-g", "openapi-generator-cli"], check=True)

def generate_flutter_client():
    props = ",".join(f"{k}={v}" for k, v in additional_properties.items())
    cmd = [
        "openapi-generator", "generate",
        "-i", openapi_file,
        "-g", generator_name,
        "-o", output_dir,
        "--additional-properties", props
    ]
    subprocess.run(cmd, check=True)
    print(f"Flutter/Dart Client generiert in: {output_dir}")

if __name__ == "__main__":
    if not os.path.exists(openapi_file):
        print(f"Datei nicht gefunden: {openapi_file}")
        sys.exit(1)

    ensure_openapi_generator_installed()
    generate_flutter_client()
