# Action OneStream Utils

A GitHub's Action to deal with OneStream's xfProjects.

Available actions are:

- ChkStrings
- GetSources
- ExtractBR



## ChkStrings

This action checks the existance of the translation in the requested languages for **all** the defined Strings in the project.

If even a single translation is missing, the action will fail (list of missing translations is available in action's logs)

Parameters are:

- ***osAction*** : ChkString
- ***osCultures*** : list of comma-separated cultures to check. If not specified the default is "it-IT,en-US,fr-FR"

Example:

      - uses: fgrande/Action-OSUtils@master
        name: Check Strings for It/En/Fr
        with:
          osAction: ChkStrings


## GetSources

This action extract the sources from the XML files, to have all the source code available in a single directory, ready to be processed with DoxyGen (or other products) to generate documentation.

Parameters are:

- ***osAction*** : GetSources
- ***osXFProject*** : The xfProject name, usually on the root of the project.
- ***osSourcesTempDir*** : The (new) directory under the project's root, to use as destination of the extracted files. If not specified, is TempSrc.
- ***osNamespacePrefix*** : The namespace to set in place of __WsNamespacePrefix placeholder.
- ***osAssemblyName*** : The assembly name to set in place of __WsAssemblyName placeholder.

Example:

      - uses: fgrande/Action-OSUtils@master
        name: Extract Sources
        with:
          osAction: GetSources
          osXFProject: AWCommons.xfProj
          osSourcesTempDir: TempSrc
          osNamespacePrefix: AWCommons
          osAssemblyName: Commons



## ExtractBR

This action extract the Business Rules sources from the XML files, to have all the source code available in a single directory, ready to be propagated for installation.

Parameters are:

- ***osAction*** : ExtractBR
- ***osXFProject*** : The xfProject name, usually on the root of the project.
- ***osSourcesTempDir*** : The (new) directory under the project's root, to use as destination of the extracted files. If not specified, is TempSrc.
- ***osSourcesTempDir*** : The (new) directory under the project's root, to use as destination of the extracted files. If not specified, is TempSrc.
- ***osVersion*** : version to put in the resulting XML file. If not specified the default is 8.5.1.17017.

Example:

      - uses: fgrande/Action-OSUtils@master
        name: Extract BRules
        with:
          osAction: ExtractBR
          osXFProject: AWUtils.xfProj
          osSourcesTempDir: TempSrc


## BuildSnippets

This action builds snippets starting from the AWSnippets project (or other projects with the same structure).

Parameters are:

- ***osAction*** : BuildSnippets
- ***snippetBaseDir*** : The root of the project.
- ***snippetZipFile*** : The final zip filename (with path).

Example:

      - uses: fgrande/Action-OSUtils@master
        name: Build Snippets
        with:
          osAction: BuildSnippets
          snippetBaseDir: 
          snippetZipFile: /tmp/AWSnippets.zip

