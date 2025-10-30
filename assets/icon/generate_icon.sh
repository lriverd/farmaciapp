#!/bin/bash

# Generar icono principal con cruz de farmacia (1024x1024)
convert -size 1024x1024 xc:"#3B693D" \
  -fill white \
  -draw "rectangle 384,256,640,768" \
  -draw "rectangle 256,384,768,640" \
  -fill "#3B693D" \
  -draw "circle 512,512 512,560" \
  icon.png

# Generar icono foreground (solo cruz blanca sobre transparente)
convert -size 1024x1024 xc:none \
  -fill white \
  -draw "rectangle 384,205,640,819" \
  -draw "rectangle 205,384,819,640" \
  icon_foreground.png

echo "✅ Iconos generados!"
