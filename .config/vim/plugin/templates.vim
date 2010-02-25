" vim:fileencoding=iso-8859-1
if has("python")
py <<EOF
"""
	Templates for VIM
	by Phillip Berndt, www.pberndt.com

	
	Phillip Berndt, Sat Apr 14 22:20:31 CEST 2007:
		Nihil (nihil <at> jabber.ccc.de) reported some problems in his
		VIM environment, which inserts a CR after the first character
		in templates. He came up with a workaround. Replace the
		imap command in the end with
			command('imap <unique> ^D ^[:py template_complete()<CR>a')
		to make it work.

"""
import sys
#sys.path.remove("")
from vim import *
from cStringIO import StringIO
import re, os
template_buffer = {}

def template_complete():
	global template_buffer

	# Check for a template
	currentPos  = current.window.cursor[1]
	template = ""
	while currentPos >= 0 and len(current.line) > 0 and not current.line[currentPos].isspace():
		template = current.line[currentPos] + template 
		currentPos = currentPos - 1
	currentPos = currentPos + 1
	
	if template is "":
		return
	
	# Search for that template
	fileType = eval("&ft")
	if fileType not in template_buffer or template not in template_buffer[fileType]:
		if fileType not in template_buffer:
			template_buffer[fileType] = {}
		searchPath = eval("g:templatePath")

		searchPaths = [
			"%s/%s/%s" % (searchPath, fileType, template),
			"%s/%s" % (searchPath, template),
			"%s/%s/%s.py" % (searchPath, fileType, template),
			"%s/%s.py" % (searchPath, template)
			]
		for templateFile in searchPaths:
			if not os.access(templateFile, os.F_OK):
				continue
			try:
				if templateFile[-3:] == ".py":
					template_buffer[fileType][template] = open(templateFile, "r").read()
				else:
					template_buffer[fileType][template] = open(templateFile, "r").readlines()
				break
			except:
				continue
		else:
			template_buffer[fileType][template] = False
	if template_buffer[fileType][template] is not False:
		# Insert template
		indention = re.search("^\s+", current.line)
		if indention is None:
			indention = ""
		else:
			indention = indention.group(0)
		endOfLine = current.line[current.window.cursor[1] + 1:]
		current.line = current.line[:currentPos]
		range = current.buffer.range(current.window.cursor[0], current.window.cursor[0])

		if type(template_buffer[fileType][template]) == str:
			# Execute as python code
			backup = sys.stdout
			sys.stdout = StringIO()
			code = template_buffer[fileType][template]
			exec code in {}, {"_vim": current, "_command": command}
			insert = sys.stdout.getvalue().split("\n")
			sys.stdout = backup
		else:
			insert = template_buffer[fileType][template]

		firstLine = True
		sentVar = False
		for line in insert:
			if line.find("<++>") is not -1:
				sentVar = True
			if firstLine:
				range.append(line)
			else:
				range.append(indention + line)
			firstLine = False
		if sentVar:
			range.append(endOfLine)
		else:
			range.append("<++>%s" % endOfLine)
		command('normal J')

command('imap <unique>  :py template_complete()<CR>a<C-J>')
EOF
endif
