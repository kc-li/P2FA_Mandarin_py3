#!/usr/bin/python

""" Usage:
      Calign.py [options] wavfile trsfile output_file
      where options may include:
          -r sampling_rate -- override which sampling rate model to use, either 8000 or 16000
          -a user_supplied_dictionary -- encoded in utf8, the dictionary will be combined with the dictionary in the model
          -d user_supplied_dictionary -- encoded in utf8, the dictionary will be used alone, NOT combined with the dictionary in the model
          -p punctuations -- encoded in utf8, punctuations and other symbols in this file will be deleted in forced alignment, the default is to use "puncs" in the model
"""

import os
import sys
import getopt
import wave
import codecs
import io

HOMEDIR = '/Users/kechun/Documents/GitHub/P2FA_changsha/run'
MODEL_DIR = HOMEDIR + '/model'

missing = io.open('MissingWords', 'w', encoding='utf8')

def prep_mlf(trsfile, tmpbase):

    f = codecs.open(tmpbase + '.dict', 'r', 'utf-8')
    lines = f.readlines()
    f.close()
    dict = []
    for line in lines:
        dict.append(line.split()[0])
    f = codecs.open(tmpbase + '.puncs', 'r', 'utf-8')
    lines = f.readlines()
    f.close()
    puncs = []
    for line in lines:
        puncs.append(line.strip())

    f = codecs.open(trsfile, 'r', 'utf-8')
    lines = f.readlines()
    f.close()

    fw = codecs.open(tmpbase + '.mlf', 'w', 'utf-8')
    fw.write('#!MLF!#\n')
    fw.write('"' + tmpbase + '.lab"\n')
    fw.write('sp\n')
    i = 0
    unks = set()
    while (i < len(lines)):
        txt = lines[i].replace('\n', '')
        txt = txt.replace('{breath}', 'br').replace('{noise}', 'ns')
        txt = txt.replace('{laugh}', 'lg').replace('{laughter}', 'lg')
        txt = txt.replace('{cough}', 'cg').replace('{lipsmack}', 'ls')
        for pun in puncs:
            txt = txt.replace(pun,  '')
        for wrd in txt.split():
            if (wrd in dict):
                fw.write(wrd + '\n')
                fw.write('sp\n')
            else:
                unks.add(wrd)
        i += 1
    fw.write('.\n')
    fw.close()
    return unks


def gen_res(infile1, infile2, outfile):

    f = codecs.open(infile1, 'r', 'utf-8')
    lines = f.readlines()
    f.close()

    f = codecs.open(infile2, 'r', 'utf-8')
    lines2 = f.readlines()
    f.close()
    words = []
    for line in lines2[2:-1]:
        if (line.strip() != 'sp'):
            words.append(line.strip())
    words.reverse()

    fw = codecs.open(outfile, 'w', 'utf-8')
    fw.write(lines[0])
    fw.write(lines[1])
    for line in lines[2:-1]:
        if ((line.split()[-1].strip() == 'sp') or (len(line.split()) != 5)):
            fw.write(line)
        else:
            fw.write(line.split()[0] + ' ' + line.split()[1] + ' ' + line.split()[2] + ' ' + line.split()[3] + ' ' + words.pop() + '\n')
    fw.write(lines[-1])

def getopt2(name, opts, default = None) :
        value = [v for n,v in opts if n==name]
        if len(value) == 0 :
                return default
        return value[0]

if __name__ == '__main__':

    try:
        opts, args = getopt.getopt(sys.argv[1:], "r:a:d:p:")

        # get the three mandatory arguments
        wavfile, trsfile, outfile = args
        # get options
        sr_override = getopt2("-r", opts)
        dict_add = getopt2("-a", opts)
        dict_alone = getopt2("-d", opts)
        puncs = getopt2("-p", opts)

    except:
        print(__doc__)
        sys.exit(0)

    tmpbase = '/tmp/' + os.environ['USER'] + '_' + str(os.getpid())

    #find sampling rate and prepare wavefile
    if sr_override:
        SR = int(sr_override)
        os.system('sox ' + wavfile + ' -r ' + str(SR) + ' ' + tmpbase + '.wav')
    else:
        f = wave.open(wavfile, 'r')
        SR = f.getframerate()
        f.close()
        if (SR not in [8000, 16000]):
            os.system('sox ' + wavfile + ' -r 16000 ' + tmpbase + '.wav')
            SR = 16000
        else:
            os.system('cp -f ' + wavfile + ' ' + tmpbase + '.wav')

    #prepare plpfile
    os.system('HCopy -C ' + MODEL_DIR + '/' + str(SR) + '/config ' + tmpbase + '.wav ' + tmpbase + '.plp')

    #prepare mlfile and dictionary
    if dict_alone:
        f = codecs.open(dict_alone, 'r', 'utf-8')
        lines = f.readlines()
        f.close()
        lines = lines + ['sp sp\n']
    else:
        f = codecs.open(MODEL_DIR + '/dict', 'r', 'utf-8')
        lines = f.readlines()
        f.close()
        if (dict_add):
            f = codecs.open(dict_add, 'r', 'utf-8')
            lines2 = f.readlines()
            f.close()
            lines = lines + lines2
    fw = codecs.open(tmpbase + '.dict', 'w', 'utf-8')
    for line in lines:
        fw.write(line)

    if puncs:
        os.system('cp -f ' + puncs + ' ' + tmpbase + '.puncs')
    else:
        os.system('cp -f ' + MODEL_DIR + '/puncs ' + tmpbase + '.puncs')

    unks = prep_mlf(trsfile, tmpbase)
    for unk in unks:
        missing.write('Missing: ' + unk + '\n')

    #run alignment
    os.system('HVite -T 1 -a -m -t 10000.0 10000.0 100000.0 -I ' + tmpbase + '.mlf -H ' + MODEL_DIR + '/' + str(SR) + '/macros -H ' + MODEL_DIR + '/' + str(SR) + '/hmmdefs -i ' + tmpbase + '.aligned' + ' ' + tmpbase + '.dict ' + MODEL_DIR + '/monophones ' + tmpbase + '.plp' + ' > ' + tmpbase + '.results')

    gen_res(tmpbase + '.aligned', tmpbase + '.mlf', outfile)

    #clean up
    os.system('rm -f ' + tmpbase + '*')
