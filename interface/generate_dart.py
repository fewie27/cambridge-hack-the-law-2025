import subprocess
import os
import sys

# Settings
openapi_file = "api.yml"
output_dir = "../frontend/counterclaimer/lib/api"
generator_name = "dart-dio"

# Generator configuration
additional_properties = {
    "pubName": "cambridge_api",
    "pubAuthor": "Cambridge Team",
    "pubVersion": "1.0.0",
    "useEnumExtension": True,
    "nullableFields": True,
    "browserClient": False,
    "supportNullSafety": True,
    "pubLibrary": "cambridge_api",
    "serializationLibrary": "json_serializable"
}

def ensure_openapi_generator_installed():
    try:
        subprocess.run(["openapi-generator", "version"], check=True, stdout=subprocess.PIPE)
    except Exception:
        print("OpenAPI Generator CLI not found. Attempting installation via Homebrew (macOS/Linux) or npm (cross-platform)...")
        if sys.platform.startswith("linux") or sys.platform == "darwin":
            subprocess.run(["brew", "install", "openapi-generator"], check=True)
        else:
            subprocess.run(["npm", "install", "-g", "openapi-generator-cli"], check=True)

def generate_flutter_client():
    # Clean the output directory first
    if os.path.exists(output_dir):
        import shutil
        shutil.rmtree(output_dir)
    os.makedirs(output_dir, exist_ok=True)

    # Generate properties string
    props = ",".join(f"{k}={v}" for k, v in additional_properties.items())
    
    cmd = [
        "openapi-generator", "generate",
        "-i", openapi_file,
        "-g", generator_name,
        "-o", output_dir,
        "--additional-properties", props
    ]
    
    try:
        subprocess.run(cmd, check=True)
        print(f"✅ Flutter/Dart client generated in: {output_dir}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating client: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if not os.path.exists(openapi_file):
        print(f"❌ File not found: {openapi_file}")
        sys.exit(1)

    ensure_openapi_generator_installed()
    generate_flutter_client()
