def read_d3_xml(xmlfile=None):
    
    """
    d3 = read_d3_xml(xmlfile)
    Read a D3 format xml file. This function is usually only used by other functions that read data from DTAG-3 tags. 

    mark johnson, danuta maria wisniewska
    14 july 2021
    
    """
    
    import os
    import xmltodict
        
    d3 = {}
    if not xmlfile:
        print(help(read_d3_xml))
        return d3
    
    if not os.path.exists(xmlfile):
        print(f' File {xmlfile} not found\n')
        return d3
    
    with open(xmlfile, 'r') as xml_file:
        dict_data = xmltodict.parse(xml_file.read())
        
    if len(dict_data.keys())==1:
        parkey = list(dict_data.keys())[0]
    else:
        print(f" Too many root keys in {xmlfile}\n")
        return d3
    
    d3 = dict_data[parkey]
    return d3