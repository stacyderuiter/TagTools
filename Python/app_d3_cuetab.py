from tagiofuns.get_d3_cuetab import get_d3_cuetab

recdir = 'F:/d4_gps_test/'
prefix = 'gps_0m_8033_'

# C = get_d3_cuetab(prefix=prefix)
C = get_d3_cuetab(recdir, prefix)
print(C.keys())