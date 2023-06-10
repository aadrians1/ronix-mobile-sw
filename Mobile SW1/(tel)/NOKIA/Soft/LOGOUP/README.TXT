
This program (gif2nol.exe) converts .gif files to .nol files.

To convert the whole directory of .gif files into .nol files
just run the batch conv_all.bat!

Remember: 1.  All .gif-files _must_ have the correct size: 72x14 pixel 
              (colordepth doesn't matter).
          2.  The .gif-file must have the format 'GIF87a non-interlaced'. 
              The newer one, 'GIF89a' ist not supported. I did not test 
              'GIF87a interlaced' - hope it works also.
              
              You may convert your 'GIF89a' file with some Tools, e.g. 
              PaintShopPro, Image ALCHEMY and so on.
              Take one of those with batch-function, so you can do all
              your files with some clicks! I took 'Image Alchemy v.1.6'.
              Command line paramaters are: 'alchemy.exe *.gif -g0 \new\*.gif'
              
If someone could send me the gif89a specs....

have fun

