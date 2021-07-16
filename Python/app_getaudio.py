from sound.get_audio import get_audio

fname = 'F:\\d4_gps_test\\gps_0m_8033_001.wav'

# sz,fs,nbits = get_audio(fname,'size')
# print(sz, fs, nbits)

x,fs,nbits = get_audio(fname,[10,20])
print(x)
x,fs,nbits = get_audio(fname,[10,20],'python')
print(x)