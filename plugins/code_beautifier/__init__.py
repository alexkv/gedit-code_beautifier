
import gedit
import gtk
import subprocess

class CodeBeautifierPlugin(gedit.Plugin):
	code_formate_str = """
		<ui>
			<menubar name="MenuBar">
				<menu name="EditMenu" action="Edit">
					<placeholder name="EditOps_6">
						<menuitem action="CodeBeautifier"/>
					</placeholder>
				</menu>
			</menubar>
		</ui>
	"""
	def __init__(self):
		gedit.Plugin.__init__(self)
#		self.__select_word_special = False

	def activate(self, window):
		actions = [
				('CodeBeautifier', None, 'Formate code','<Control><Alt>l', '', self.format_code),
		]
		
		windowdata = dict()
		window.set_data("CodeBeautifierPluginWindowDataKey", windowdata)
		windowdata["action_group"] = gtk.ActionGroup("CodeBeautifierPluginWindowDataKey")
		windowdata["action_group"].add_actions(actions, window)
		manager = window.get_ui_manager()
		manager.insert_action_group(windowdata["action_group"], -1)
		windowdata["ui_id"] = manager.add_ui_from_string(self.code_formate_str)
		window.set_data("CodeBeautifierPluginInfo", windowdata)


	def deactivate(self, window):
		windowdata = window.get_data("CodeBeautifierPluginWindowDataKey")
		manager = window.get_ui_manager()
		manager.remove_ui(windowdata["ui_id"])
		manager.remove_action_group(windowdata["action_group"])


	def format_code(self, action, window):
		document = window.get_active_document()
		start, end = document.get_bounds()
		code = document.get_text(start, end)
		lang_id = window.get_active_view().get_buffer().get_language().get_id()
		result = self.go(code, lang_id)
		document.set_text(result)


	def go (self, code, lang_id):
		if lang_id == 'ruby':
			command = ["ruby ~/.gnome2/gedit/plugins/code_beautifier/ruby.rb - "]
		elif lang_id in ['php', 'c', 'c++', 'java', 'js']:
			command = ["~/.gnome2/gedit/plugins/code_beautifier/astyle --style=java --indent=tab"]
		else:
			return code
		
		process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
		process.stdin.write(code)
		process.stdin.close()
		return process.stdout.read()
		
