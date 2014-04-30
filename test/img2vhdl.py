#!/usr/bin/python
from PIL import Image
im = Image.open ("1.png")
rgb_im = im.convert('RGB')
pix = rgb_im.load()
w, h = rgb_im.size
print "w= %d h= %d" % (w,h)

print '('
for y in range(h):
	print '  (',
	for x in range(w):
		r = int(pix[x, y][0]/255.0 * 7 + 0.5)
		g = int(pix[x, y][1]/255.0 * 7 + 0.5)
		b = int(pix[x, y][2]/255.0 * 3 + 0.5)

		r = "{0:03b}".format(r)
		g = "{0:03b}".format(g)
		b = "{0:02b}".format(b)
		tmp = '%s%s%s' % (r,g,b)
		print int(tmp, 2),
		if x < w - 1:
			print ',',
	if y < h - 1:
		print '),'
	else: 
		print ')'
print ');'
