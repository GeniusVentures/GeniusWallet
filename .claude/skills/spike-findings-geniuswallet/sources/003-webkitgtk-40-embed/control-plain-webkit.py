# Control: plain WebKitGTK 4.0 window, no Flutter, no plugin.
import sys, time, gi
gi.require_version('Gtk', '3.0'); gi.require_version('WebKit2', '4.0')
from gi.repository import Gtk, WebKit2, GLib
t0 = time.time()
w = Gtk.Window(title='control'); w.set_default_size(1280, 640)
v = WebKit2.WebView(); w.add(v)
def changed(view, ev):
    print('%.1fs load %s %s' % (time.time()-t0, ev.value_nick, view.get_uri()), flush=True)
v.connect('load-changed', changed)
def probe():
    def done(view, res):
        try:
            r = view.run_javascript_finish(res).get_js_value().to_string()
        except Exception as e:
            r = 'ERR %s' % e
        print('%.1fs probe %s' % (time.time()-t0, r[:300]), flush=True)
    v.run_javascript("document.title+' | ready='+document.readyState+' | len='+document.body.innerText.length+' | '+document.body.innerText.slice(0,120)", None, done)
    return True
GLib.timeout_add_seconds(8, probe)
v.load_uri(sys.argv[1]); w.show_all()
GLib.timeout_add_seconds(int(sys.argv[2]), Gtk.main_quit)
Gtk.main()
