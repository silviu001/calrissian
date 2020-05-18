cwlVersion: v1.0
class: CommandLineTool
requirements:
  DockerRequirement:
    dockerPull: images.geomatys.com/ndvis:latest
inputs:
  files:
    inputBinding:
      position: 1
    type:
      type: array
      items: File
outputs:
  output:
    outputBinding:
      glob: out.tif
    type: File