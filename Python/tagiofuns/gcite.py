def gcite(doi=None, opage=False):
    
    """
      Get citation (gcite) information from the web using an 'objects' doi number (digital object identifier).
      
      cite, bibf = gcite(doi)
      or 
      cite, bibf = gcite(doi, opage)

      Inputs:
      doi number as a string. The doi number can be entered as a url ('https://doi.org/10.1109/JOE.2002.808212') or as a number ('10.1109/JOE.2002.808212'). 
          The function checks for the mssing host address and appends it to the doi number
      opage is an optional boolean argument to open the project archive / webpage

      Outputs:
      cite APA-formatted citation
      bibf bibtex-formatted citation

      Examples
      cite,_ = gcite('https://doi.org/10.1109/JOE.2002.808212')
      print(cite) returns:
      Johnson, M. P., & Tyack, P. L. (2003). A digital acoustic recording tag for measuring the response of wild marine mammals to sound. IEEE Journal of Oceanic Engineering, 28(1), 3–12. doi:10.1109/joe.2002.808212

      cite, bibf = gcite('10.1109/JOE.2002.808212')
      print(cite) returns:
      Johnson, M. P., & Tyack, P. L. (2003). A digital acoustic recording tag for measuring the response of wild marine mammals to sound. IEEE Journal of Oceanic Engineering, 28(1), 3–12. doi:10.1109/joe.2002.808212
      
      print(bibf) returns:
      @article{Johnson_2003,
            doi = {10.1109/joe.2002.808212},
            url = {https://doi.org/10.1109%2Fjoe.2002.808212},
            year = 2003,
            month = {jan},
            publisher = {Institute of Electrical and Electronics Engineers ({IEEE})},
            volume = {28},
            number = {1},
            pages = {3--12},
            author = {M.P. Johnson and P.L. Tyack},
            title = {A digital acoustic recording tag for measuring the response of wild marine mammals to sound},
            journal = {{IEEE} Journal of Oceanic Engineering}
       }

    Valid: Python
    rjs30@st-andrews.ac.uk
    Python implementation dmwisniewska@gmail.com
    last modified: 23 July 2021
    
    """
    
    import subprocess
    
    cite, bibf = ([] for i in range(2))

    if not doi or not isinstance(doi, str):
        print(help(gcite))
        return (cite, bibf)

    if not opage:
        opage = 0

    # Check for missing host address
    if doi.find('https://doi.org/')<0:
        doi = 'https://doi.org/' + doi

    # Get formatted citation (APA style)
    command = 'curl -LH "Accept: text/x-bibliography; style=apa" ' + doi
    res = subprocess.check_output(command)
    cite = res.decode("utf-8")

    # Get bibtex-formatted citation info
    command = 'curl -LH "Accept: application/x-bibtex" ' + doi 
    res = subprocess.check_output(command)
    bibf = res.decode("utf-8")

    # Open webpage
    if opage:
        import webbrowser
        webbrowser.open_new_tab(doi)

    return (cite, bibf)