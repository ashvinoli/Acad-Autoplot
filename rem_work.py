import shutil
import subprocess
import sys
import os

exp_to = ['svg', 'png']

def convert():
    if shutil.which('inkscape'):
        pdf_files = [f for f in os.listdir(sys.argv[1]) if f.endswith('.pdf')]
        for f in pdf_files:
            complete_path = os.path.join(sys.argv[1], f)
            for exp_type in exp_to:
                subprocess.call(['inkscape', '-D', f'--export-type={exp_type}', complete_path])
            print(f"{complete_path} converted!")
    else:
        print('Inkscape not found! Reinstall inkscape 1.2 and make sure it is in path.')


def main():
    convert()

if __name__ == '__main__':
    main()
