# Datamosh

Manipulates image data to create digital art.  

This program has two different algorithm sto choose from. The first replaces image data with junk data and the second uses sox to apply audio effects to the image.

## Dependencies  
Requires imagemagick and sox
```sh
sudo apt install imagemagick
sudo apt install sox
```

## Usage
```sh
./main.sh <filename> [-s] [-v] [-o <value>]
```

|Argument Command|Example Usage|Description|
|----|----|----|
|-s|./main.sh -s|Use sox instead of default algorithm to edit data|
|-v|./main.sh -v|Overlays output on top of original image|
|-o|./main.sh -o <filename>|Set output location of image|
 
