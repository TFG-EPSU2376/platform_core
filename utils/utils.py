import json
import subprocess

def get_terraform_output(output_name):
    result = subprocess.run(['terraform', 'output', '-json'], capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)
    print(result)
    outputs = json.loads(result.stdout)
    print(outputs)
    return outputs[output_name]['value']