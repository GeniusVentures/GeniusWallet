# Control: plain WebKitGTK 4.0, media-stream on; is getUserMedia available at all?
import sys, gi
gi.require_version('Gtk', '3.0'); gi.require_version('WebKit2', '4.0')
from gi.repository import Gtk, WebKit2, GLib
print('webkit', WebKit2.get_major_version(), WebKit2.get_minor_version(), WebKit2.get_micro_version())
w = Gtk.Window(title='control'); v = WebKit2.WebView(); w.add(v)
s = v.get_settings()
for p in ['enable-media-stream', 'enable-mediasource', 'enable-webrtc', 'enable-media', 'enable-mock-capture-devices']:
    try:
        s.set_property(p, True); print(p, s.get_property(p))
    except Exception as e:
        print(p, 'n/a', e)
def perm(view, req):
    print('permission-request', type(req).__name__, flush=True); req.allow(); return True
v.connect('permission-request', perm)
def probe():
    def done(view, res):
        print('probe', view.run_javascript_finish(res).get_js_value().to_string(), flush=True)
    v.run_javascript("String(typeof navigator.mediaDevices)+' secure='+isSecureContext", None, done)
    v.run_javascript("runGum()", None, None)
    return False
v.load_html("<script>async function runGum(){try{await navigator.mediaDevices.getUserMedia({video:true});document.title='OK'}catch(e){document.title=e.name+': '+e.message}}</script>", "http://127.0.0.1/")
w.show_all()
GLib.timeout_add_seconds(2, probe)
GLib.timeout_add_seconds(6, lambda: (print('title', v.get_title()), Gtk.main_quit()))
Gtk.main()
