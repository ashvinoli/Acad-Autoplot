import shutil
import subprocess
import os
import sys

exp_to = ['svg', 'png']

def convert():
    if shutil.which('inkscape'):
        dir_path = os.path.dirname(os.path.realpath(__file__))
        pdf_files = [f for f in os.listdir(dir_path) if (f.endswith('.pdf') and f.startswith(sys.argv[1]))] 
        for f in pdf_files:
            complete_path = os.path.join(dir_path, f)
            for exp_type in exp_to:
                subprocess.call(['inkscape', '-D', f'--export-type={exp_type}', complete_path])
            print(f"{complete_path} converted!")
    else:
        print('Inkscape not found! Reinstall inkscape 1.2 and make sure it is in path.')


def main():
    convert()

if __name__ == '__main__':
    main()
