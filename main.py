"""
Calc Pro - A full-featured mobile calculator built with Kivy
"""

import math
import json
import os
from kivy.app import App
from kivy.clock import Clock
from kivy.core.window import Window
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.scrollview import ScrollView
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.widget import Widget
from kivy.uix.popup import Popup
from kivy.graphics import Color, RoundedRectangle, Rectangle
from kivy.metrics import dp, sp
from kivy.utils import platform
from kivy.animation import Animation
from kivy.properties import (
    StringProperty, NumericProperty, BooleanProperty,
    ListProperty, ObjectProperty, ColorProperty
)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
HISTORY_FILE = 'calc_history.json'
THEME_FILE = 'calc_theme.json'

THEMES = {
    'dark': {
        'bg': (0.102, 0.102, 0.180, 1),
        'surface': (0.086, 0.129, 0.243, 1),
        'display': (0.059, 0.204, 0.376, 1),
        'primary': (0.914, 0.271, 0.376, 1),
        'primary_text': (1, 1, 1, 1),
        'secondary': (0.325, 0.204, 0.514, 1),
        'btn_num': (0.102, 0.102, 0.243, 1),
        'btn_num_text': (1, 1, 1, 1),
        'btn_op': (0.165, 0.165, 0.369, 1),
        'btn_op_text': (0.914, 0.271, 0.376, 1),
        'btn_eq': (0.914, 0.271, 0.376, 1),
        'btn_eq_text': (1, 1, 1, 1),
        'btn_clear': (0.325, 0.204, 0.514, 1),
        'btn_clear_text': (1, 1, 1, 1),
        'text': (1, 1, 1, 1),
        'text_secondary': (0.627, 0.627, 0.722, 1),
        'history_bg': (0.118, 0.118, 0.227, 1),
        'scrollbar': (0.165, 0.165, 0.369, 1),
        'tab_bg': (0.165, 0.165, 0.369, 0.3),
        'tab_active': (0.165, 0.165, 0.369, 1),
        'gradient_start': (0.914, 0.271, 0.376, 1),
        'gradient_end': (0.325, 0.204, 0.514, 1),
        'header_text': (1, 1, 1, 1),
        'mem_indicator': (0.914, 0.271, 0.376, 1),
    },
    'light': {
        'bg': (0.943, 0.947, 0.960, 1),
        'surface': (1, 1, 1, 1),
        'display': (0.973, 0.976, 0.980, 1),
        'primary': (0.914, 0.271, 0.376, 1),
        'primary_text': (1, 1, 1, 1),
        'secondary': (0.486, 0.302, 1.0, 1),
        'btn_num': (0.961, 0.961, 0.961, 1),
        'btn_num_text': (0.102, 0.102, 0.180, 1),
        'btn_op': (0.910, 0.918, 0.965, 1),
        'btn_op_text': (0.914, 0.271, 0.376, 1),
        'btn_eq': (0.914, 0.271, 0.376, 1),
        'btn_eq_text': (1, 1, 1, 1),
        'btn_clear': (0.486, 0.302, 1.0, 1),
        'btn_clear_text': (1, 1, 1, 1),
        'text': (0.102, 0.102, 0.180, 1),
        'text_secondary': (0.4, 0.4, 0.4, 1),
        'history_bg': (0.973, 0.976, 0.980, 1),
        'scrollbar': (0.8, 0.8, 0.8, 1),
        'tab_bg': (0.910, 0.918, 0.965, 0.3),
        'tab_active': (0.910, 0.918, 0.965, 1),
        'gradient_start': (0.914, 0.271, 0.376, 1),
        'gradient_end': (0.486, 0.302, 1.0, 1),
        'header_text': (0.102, 0.102, 0.180, 1),
        'mem_indicator': (0.914, 0.271, 0.376, 1),
    }
}

# ---------------------------------------------------------------------------
# Styled Button
# ---------------------------------------------------------------------------
class CalcButton(Button):
    bg_color = ListProperty([0.2, 0.2, 0.4, 1])
    bg_color_pressed = ListProperty([0.3, 0.3, 0.5, 1])
    corner_radius = NumericProperty(dp(12))
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.font_size = sp(20)
        self.bold = True
        self.background_color = (0, 0, 0, 0)
        self.background_normal = ''
        self.background_down = ''
        self.size_hint = (1, 1)
        self.bind(pos=self._redraw, size=self._redraw)
        Clock.schedule_once(self._redraw)
    
    def _redraw(self, *args):
        self.canvas.before.clear()
        with self.canvas.before:
            Color(*self.bg_color)
            w, h = self.size
            RoundedRectangle(pos=self.pos, size=self.size, radius=[self.corner_radius]*4)
    
    def on_touch_down(self, touch):
        if self.collide_point(*touch.pos):
            self.canvas.before.clear()
            with self.canvas.before:
                Color(*self.bg_color_pressed)
                w, h = self.size
                RoundedRectangle(pos=self.pos, size=self.size, radius=[self.corner_radius]*4)
            return super().on_touch_down(touch)
        return super().on_touch_down(touch)
    
    def on_touch_up(self, touch):
        self._redraw()
        return super().on_touch_up(touch)


class SciButton(CalcButton):
    pass


# ---------------------------------------------------------------------------
# Display Label
# ---------------------------------------------------------------------------
class DisplayLabel(Label):
    pass


# ---------------------------------------------------------------------------
# Main Calculator Widget
# ---------------------------------------------------------------------------
class CalculatorWidget(BoxLayout):
    expression_text = StringProperty('')
    result_text = StringProperty('0')
    theme_name = StringProperty('dark')
    is_radian = BooleanProperty(False)
    has_memory = BooleanProperty(False)
    show_sci = BooleanProperty(False)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.expression = ''
        self.current = '0'
        self.memory = 0.0
        self.has_mem = False
        self.history = []
        self.is_new_entry = True
        self.just_evaluated = False
        self.paren_count = 0
        self.last_answer = None
        self.orientation = 'vertical'
        self.padding = [0, 0, 0, 0]
        self.spacing = 0
        
        self.load_history()
        self.load_theme()
        self.build_ui()
    
    def build_ui(self):
        self.clear_widgets()
        theme = THEMES[self.theme_name]
        
        # Header
        header = BoxLayout(
            size_hint=(1, None), height=dp(52),
            padding=[dp(16), dp(8), dp(16), dp(4)]
        )
        with header.canvas.before:
            Color(*theme['surface'])
            self._header_bg = RoundedRectangle(pos=header.pos, size=header.size)
        header.bind(pos=self._update_header_bg, size=self._update_header_bg)
        
        title = Label(
            text='Calc Pro', font_size=sp(20), bold=True,
            color=theme['header_text'], halign='left', valign='middle',
            size_hint_x=0.4
        )
        title.bind(size=title.setter('text_size'))
        header.add_widget(title)
        
        header.add_widget(Widget())  # spacer
        
        hbox = BoxLayout(size_hint_x=0.6, spacing=dp(4))
        btn_rad = Button(
            text='DEG', font_size=sp(12), bold=True,
            color=theme['btn_op_text'],
            background_color=(0,0,0,0),
            background_normal='', size_hint=(None, 1), width=dp(44)
        )
        btn_rad.bind(on_press=lambda x: self.toggle_angle_mode(btn_rad))
        hbox.add_widget(btn_rad)
        
        btn_mem = Button(
            text='M', font_size=sp(14), bold=True,
            color=theme['btn_op_text'],
            background_color=(0,0,0,0),
            background_normal='', size_hint=(None, 1), width=dp(36)
        )
        btn_mem.bind(on_press=lambda x: self.show_memory_menu())
        hbox.add_widget(btn_mem)
        
        btn_theme = Button(
            text='☀️' if self.theme_name == 'light' else '🌙',
            font_size=sp(16),
            background_color=(0,0,0,0),
            background_normal='', size_hint=(None, 1), width=dp(36)
        )
        btn_theme.bind(on_press=lambda x: self.toggle_theme())
        hbox.add_widget(btn_theme)
        
        btn_hist = Button(
            text='📋', font_size=sp(16),
            background_color=(0,0,0,0),
            background_normal='', size_hint=(None, 1), width=dp(36)
        )
        btn_hist.bind(on_press=lambda x: self.toggle_history())
        hbox.add_widget(btn_hist)
        
        header.add_widget(hbox)
        self.add_widget(header)
        
        # Mem indicator
        self.mem_label = Label(
            text='', font_size=sp(10), bold=True,
            color=theme['mem_indicator'],
            size_hint=(1, None), height=dp(16),
            halign='right', valign='middle',
            padding=[0, 0, dp(20), 0]
        )
        self.mem_label.bind(size=self.mem_label.setter('text_size'))
        self.add_widget(self.mem_label)
        
        # Display
        display = BoxLayout(
            size_hint=(1, None), height=dp(130),
            padding=[dp(16), dp(8), dp(16), dp(12)]
        )
        with display.canvas.before:
            Color(*theme['display'])
            self._display_bg = RoundedRectangle(pos=display.pos, size=display.size, radius=[dp(16)]*4)
        display.bind(pos=self._update_display_bg, size=self._update_display_bg)
        
        disp_inner = BoxLayout(orientation='vertical')
        self.expr_label = Label(
            text='', font_size=sp(15),
            color=theme['text_secondary'],
            halign='right', valign='bottom',
            size_hint=(1, 0.4),
            text_size=(None, None),
            font_name='RobotoMono-Regular'
        )
        disp_inner.add_widget(self.expr_label)
        
        self.result_label = Label(
            text='0', font_size=sp(42), bold=True,
            color=theme['text'],
            halign='right', valign='bottom',
            size_hint=(1, 0.6),
            font_name='RobotoMono-Regular'
        )
        disp_inner.add_widget(self.result_label)
        
        display.add_widget(disp_inner)
        self.add_widget(display)
        
        # Tabs
        tabs = BoxLayout(
            size_hint=(1, None), height=dp(38),
            padding=[dp(16), 0, dp(16), dp(6)]
        )
        self.tab_basic = Button(
            text='Basic', font_size=sp(13), bold=True,
            background_color=(0,0,0,0),
            background_normal='',
            color=theme['text'],
            size_hint_x=0.5
        )
        self.tab_sci = Button(
            text='Scientific', font_size=sp(13), bold=True,
            background_color=(0,0,0,0),
            background_normal='',
            color=theme['text_secondary'],
            size_hint_x=0.5
        )
        self.tab_basic.bind(on_press=lambda x: self.switch_tab('basic'))
        self.tab_sci.bind(on_press=lambda x: self.switch_tab('sci'))
        # Tab bg
        with tabs.canvas.before:
            Color(*theme['tab_bg'])
            self._tabs_bg = RoundedRectangle(pos=tabs.pos, size=tabs.size, radius=[dp(20)]*4)
        tabs.bind(pos=self._update_tabs_bg, size=self._update_tabs_bg)
        
        tabs.add_widget(self.tab_basic)
        tabs.add_widget(self.tab_sci)
        self.add_widget(tabs)
        
        # Button area
        btn_area = BoxLayout(
            size_hint=(1, 1),
            padding=[dp(8), dp(4), dp(8), dp(12)]
        )
        
        self.basic_grid = self._make_basic_grid()
        self.sci_grid = self._make_sci_grid()
        self.sci_grid.opacity = 0
        
        btn_area.add_widget(self.basic_grid)
        btn_area.add_widget(self.sci_grid)
        self.add_widget(btn_area)
        
        # History panel (overlay)
        self.history_active = False
        
        self.update_display()
    
    def _make_basic_grid(self):
        grid = GridLayout(cols=4, spacing=dp(7), size_hint=(1, 1))
        buttons = [
            ('AC', 'clear', 'clear'), ('⌫', 'backspace', 'clear'),
            ('%', 'percent', 'op'), ('÷', 'divide', 'op'),
            ('7', '7', 'num'), ('8', '8', 'num'), ('9', '9', 'num'),
            ('×', 'multiply', 'op'),
            ('4', '4', 'num'), ('5', '5', 'num'), ('6', '6', 'num'),
            ('−', 'subtract', 'op'),
            ('1', '1', 'num'), ('2', '2', 'num'), ('3', '3', 'num'),
            ('+', 'add', 'op'),
            ('0', '0', 'num'), ('.', 'decimal', 'num'),
            ('=', 'equals', 'eq'),
        ]
        for text, action, btn_type in buttons:
            btn = self._create_btn(text, action, btn_type)
            grid.add_widget(btn)
        return grid
    
    def _make_sci_grid(self):
        grid = GridLayout(cols=5, spacing=dp(6), size_hint=(1, 1))
        buttons = [
            ('sin', 'sin', 'func'), ('cos', 'cos', 'func'), ('tan', 'tan', 'func'),
            ('log', 'log', 'func'), ('ln', 'ln', 'func'),
            ('sin⁻¹', 'asin', 'func'), ('cos⁻¹', 'acos', 'func'), ('tan⁻¹', 'atan', 'func'),
            ('√', 'sqrt', 'func'), ('∛', 'cbrt', 'func'),
            ('x²', 'square', 'func'), ('x³', 'cube', 'func'), ('xʸ', 'power', 'func'),
            ('x!', 'factorial', 'func'), ('1/x', 'reciprocal', 'func'),
            ('π', 'pi', 'func'), ('e', 'econst', 'func'), ('eˣ', 'exp', 'func'),
            ('10ˣ', 'tenx', 'func'), ('|x|', 'abs', 'func'),
            ('AC', 'clear', 'clear'), ('⌫', 'backspace', 'clear'),
            ('%', 'percent', 'op'), ('÷', 'divide', 'op'), ('×', 'multiply', 'op'),
            ('7', '7', 'num'), ('8', '8', 'num'), ('9', '9', 'num'),
            ('−', 'subtract', 'op'), ('+', 'add', 'op'),
            ('4', '4', 'num'), ('5', '5', 'num'), ('6', '6', 'num'),
            ('(', 'lparen', 'func'), (')', 'rparen', 'func'),
            ('1', '1', 'num'), ('2', '2', 'num'), ('3', '3', 'num'),
            ('0', '0', 'num'), ('.', 'decimal', 'num'),
            ('±', 'negate', 'func'), ('=', 'equals', 'eq'),
        ]
        for text, action, btn_type in buttons:
            btn = self._create_btn(text, action, btn_type, sci=True)
            grid.add_widget(btn)
        return grid
    
    def _create_btn(self, text, action, btn_type, sci=False):
        theme = THEMES[self.theme_name]
        bg_map = {
            'num': theme['btn_num'],
            'op': theme['btn_op'],
            'eq': theme['btn_eq'],
            'clear': theme['btn_clear'],
            'func': theme['btn_op'],
        }
        text_map = {
            'num': theme['btn_num_text'],
            'op': theme['btn_op_text'],
            'eq': theme['btn_eq_text'],
            'clear': theme['btn_clear_text'],
            'func': theme['text_secondary'],
        }
        font_sizes = {
            'num': sp(20), 'op': sp(20), 'eq': sp(24),
            'clear': sp(16), 'func': sp(14)
        }
        
        btn = CalcButton(
            text=text,
            bg_color=bg_map.get(btn_type, theme['btn_num']),
            bg_color_pressed=[min(c+0.08, 1) for c in bg_map.get(btn_type, theme['btn_num'])],
            font_size=font_sizes.get(btn_type, sp(18))
        )
        btn.color = text_map.get(btn_type, theme['text'])
        if btn_type == 'func':
            btn.font_size = sp(13)
            btn.bold = False
        if btn_type == 'clear':
            btn.font_size = sp(16)
        btn.action = action
        btn.bind(on_press=self.on_btn_press)
        return btn
    
    # ----- Button press handler -----
    def on_btn_press(self, btn):
        action = btn.action
        if hasattr(btn, 'action_val'):
            action = btn.action_val
        
        if action in [str(i) for i in range(10)]:
            self.input_digit(action)
        elif action == 'decimal':
            self.input_decimal()
        elif action in ('add', 'subtract', 'multiply', 'divide', 'percent', 'power'):
            op_map = {
                'add': '+', 'subtract': '-', 'multiply': '*',
                'divide': '/', 'percent': '%', 'power': '^'
            }
            self.input_operator(op_map[action])
        elif action == 'equals':
            self.calculate()
        elif action == 'clear':
            self.clear_all()
        elif action == 'backspace':
            self.backspace()
        elif action == 'negate':
            self.negate()
        elif action == 'lparen':
            self.input_lparen()
        elif action == 'rparen':
            self.input_rparen()
        elif action in ('sin', 'cos', 'tan', 'asin', 'acos', 'atan',
                        'log', 'ln', 'sqrt', 'cbrt', 'square', 'cube',
                        'reciprocal', 'factorial', 'pi', 'econst',
                        'exp', 'tenx', 'abs'):
            self.input_function(action)
    
    # ----- Input methods -----
    def input_digit(self, digit):
        if self.just_evaluated:
            self.expression = ''
            self.current = '0'
            self.just_evaluated = False
        
        if self.is_new_entry:
            self.current = digit
            self.is_new_entry = False
        else:
            if self.current == '0':
                self.current = digit
            else:
                if len(self.current) < 16:
                    self.current += digit
        self.update_display()
    
    def input_decimal(self):
        if self.just_evaluated:
            self.expression = ''
            self.current = '0.'
            self.just_evaluated = False
            self.is_new_entry = False
            self.update_display()
            return
        if self.is_new_entry:
            self.current = '0.'
            self.is_new_entry = False
            self.update_display()
            return
        if '.' not in self.current:
            self.current += '.'
        self.update_display()
    
    def input_operator(self, op):
        self.just_evaluated = False
        self.is_new_entry = False
        
        display_op = {'+': '+', '-': '−', '*': '×', '/': '÷', '^': '^', '%': '%'}.get(op, op)
        expr_op = {'+': '+', '-': '-', '*': '×', '/': '÷', '^': '^', '%': '%'}.get(op, op)
        
        expr = self.expression
        
        if self.current != '0' and not self.is_new_entry:
            if expr and expr[-1] == ')':
                expr += ' ' + expr_op
            else:
                expr += self._unformat(self.current)
        
        last = expr[-1] if expr else ''
        if last in '+-×÷^' or last == '(' or expr == '':
            if last in '+-×÷^':
                expr = expr[:-1].strip()
        
        if op == '%':
            try:
                val = float(self.current) / 100
                self.current = str(val)
                expr += self._unformat(self.current)
            except:
                self.current = 'Error'
            self.expression = expr + '%'
            self.update_display()
            self.is_new_entry = True
            return
        
        expr += ' ' + expr_op + ' '
        self.expression = expr
        self.current = '0'
        self.is_new_entry = True
        self.update_display()
    
    def input_function(self, fn):
        self.just_evaluated = False
        expr = self.expression
        cur = self._unformat(self.current)
        
        if fn == 'pi':
            if not self.is_new_entry and self.current != '0':
                expr += cur
            expr += 'π'
            self.expression = expr
            self.current = str(math.pi)
            self.is_new_entry = True
        elif fn == 'econst':
            if not self.is_new_entry and self.current != '0':
                expr += cur
            expr += 'e'
            self.expression = expr
            self.current = str(math.e)
            self.is_new_entry = True
        elif fn == 'square':
            v = float(self.current)
            r = v * v
            expr += cur + '²'
            self.expression = expr
            self.current = str(r)
            self.is_new_entry = True
        elif fn == 'cube':
            v = float(self.current)
            r = v * v * v
            expr += cur + '³'
            self.expression = expr
            self.current = str(r)
            self.is_new_entry = True
        elif fn == 'sqrt':
            expr += '√(' + cur + ')'
            self.expression = expr
            self.current = str(math.sqrt(float(self.current)))
            self.is_new_entry = True
        elif fn == 'cbrt':
            expr += '∛(' + cur + ')'
            self.expression = expr
            self.current = str(math.cbrt(float(self.current)))
            self.is_new_entry = True
        elif fn == 'reciprocal':
            v = float(self.current)
            if v == 0:
                self.show_toast('Cannot divide by zero')
                return
            expr += '1/(' + cur + ')'
            self.expression = expr
            self.current = str(1.0 / v)
            self.is_new_entry = True
        elif fn == 'factorial':
            v = float(self.current)
            if v < 0 or v != int(v):
                self.show_toast('Integer >= 0 only')
                return
            f = 1
            for i in range(2, int(v) + 1):
                f *= i
            expr += cur + '!'
            self.expression = expr
            self.current = str(f)
            self.is_new_entry = True
        elif fn == 'negate':
            self.current = str(-float(self.current))
        elif fn == 'power':
            self.input_operator('^')
            return
        elif fn in ('sin', 'cos', 'tan', 'asin', 'acos', 'atan',
                    'log', 'ln', 'exp', 'tenx', 'abs'):
            display_names = {
                'sin': 'sin', 'cos': 'cos', 'tan': 'tan',
                'asin': 'asin', 'acos': 'acos', 'atan': 'atan',
                'log': 'log', 'ln': 'ln', 'exp': 'exp',
                'tenx': 'tenx', 'abs': 'abs'
            }
            v = float(self.current)
            try:
                if fn == 'sin':
                    r = math.sin(v) if self.is_radian else math.sin(math.radians(v))
                elif fn == 'cos':
                    r = math.cos(v) if self.is_radian else math.cos(math.radians(v))
                elif fn == 'tan':
                    r = math.tan(v) if self.is_radian else math.tan(math.radians(v))
                elif fn == 'asin':
                    r = math.asin(v) if self.is_radian else math.degrees(math.asin(v))
                elif fn == 'acos':
                    r = math.acos(v) if self.is_radian else math.degrees(math.acos(v))
                elif fn == 'atan':
                    r = math.atan(v) if self.is_radian else math.degrees(math.atan(v))
                elif fn == 'log':
                    r = math.log10(v) if v > 0 else float('nan')
                elif fn == 'ln':
                    r = math.log(v) if v > 0 else float('nan')
                elif fn == 'exp':
                    r = math.exp(v)
                elif fn == 'tenx':
                    r = math.pow(10, v)
                elif fn == 'abs':
                    r = abs(v)
                else:
                    r = v
                
                name = display_names.get(fn, fn)
                expr += f'{name}({cur})'
                self.expression = expr
                self.current = str(r)
                self.is_new_entry = True
            except Exception as e:
                self.current = 'Error'
        
        self.update_display()
    
    def input_lparen(self):
        if self.just_evaluated:
            self.expression = ''
            self.current = '0'
            self.just_evaluated = False
        self.expression += '('
        self.paren_count += 1
        self.update_display()
    
    def input_rparen(self):
        if self.paren_count <= 0:
            return
        self.expression += ')'
        self.paren_count -= 1
        self.update_display()
    
    def clear_all(self):
        self.expression = ''
        self.current = '0'
        self.is_new_entry = True
        self.just_evaluated = False
        self.paren_count = 0
        self.update_display()
    
    def backspace(self):
        if self.just_evaluated:
            self.clear_all()
            return
        if self.is_new_entry:
            return
        if len(self.current) > 1:
            self.current = self.current[:-1]
        else:
            self.current = '0'
            self.is_new_entry = True
        self.update_display()
    
    def negate(self):
        try:
            self.current = str(-float(self.current))
        except:
            pass
        self.update_display()
    
    # ----- Evaluation -----
    def calculate(self):
        expr = self.expression
        if not expr:
            self.current = '0'
            self.is_new_entry = True
            self.update_display()
            return
        
        open_count = expr.count('(')
        close_count = expr.count(')')
        while close_count < open_count:
            expr += ')'
            close_count += 1
        
        last = expr[-1] if expr else ''
        if last in '+-×÷^(' or last == '' or last == ' ':
            return
        
        # Append current value if needed
        if not self.is_new_entry and self.current != '0':
            if last not in ')' and expr:
                expr += self._unformat(self.current)
        
        result = self._evaluate(expr)
        if result is None or not math.isfinite(result):
            self.current = 'Error'
            self.expression = expr
            self.update_display()
            return
        
        result_str = str(round(result, 12))
        display_expr = expr
        self.save_history(display_expr + ' =', self._format_num(result_str))
        self.expression = expr
        self.current = result_str
        self.is_new_entry = True
        self.just_evaluated = True
        self.last_answer = result_str
        self.update_display()
    
    def _evaluate(self, expr):
        sanitized = expr
        sanitized = sanitized.replace('×', '*').replace('÷', '/').replace('−', '-')
        sanitized = sanitized.replace('π', str(math.pi)).replace('²', '**2').replace('³', '**3')
        sanitized = sanitized.replace('√', 'math.sqrt')
        
        # Replace e but not exp
        sanitized = sanitized.replace('e', str(math.e))
        # But fix the exp case
        sanitized = sanitized.replace(str(math.e) + 'xp', 'math.exp')
        
        sanitized = sanitized.replace('^', '**')
        sanitized = sanitized.replace('mod', '%')
        
        # Insert * between number and (
        import re
        sanitized = re.sub(r'(\d)\(', r'\1*(', sanitized)
        sanitized = re.sub(r'\)\(', r')*(', sanitized)
        sanitized = re.sub(r'\)(\d)', r')*\1', sanitized)
        
        sanitized = re.sub(r'(?<!\w)sin\(', 'math.sin(', sanitized)
        sanitized = re.sub(r'(?<!\w)cos\(', 'math.cos(', sanitized)
        sanitized = re.sub(r'(?<!\w)tan\(', 'math.tan(', sanitized)
        sanitized = re.sub(r'(?<!\w)asin\(', 'math.asin(', sanitized)
        sanitized = re.sub(r'(?<!\w)acos\(', 'math.acos(', sanitized)
        sanitized = re.sub(r'(?<!\w)atan\(', 'math.atan(', sanitized)
        sanitized = re.sub(r'(?<!\w)log\(', 'math.log10(', sanitized)
        sanitized = re.sub(r'(?<!\w)ln\(', 'math.log(', sanitized)
        sanitized = re.sub(r'(?<!\w)sqrt\(', 'math.sqrt(', sanitized)
        sanitized = re.sub(r'(?<!\w)cbrt\(', 'math.cbrt(', sanitized)
        sanitized = re.sub(r'(?<!\w)abs\(', 'fabs(', sanitized)
        sanitized = re.sub(r'(?<!\w)exp\(', 'math.exp(', sanitized)
        sanitized = re.sub(r'tenx\(', 'pow(10,', sanitized)
        
        if not self.is_radian:
            sanitized = re.sub(
                r'math\.(sin|cos|tan)\(([^)]+)\)',
                lambda m: f'math.{m.group(1)}(math.radians({m.group(2)}))',
                sanitized
            )
            sanitized = re.sub(
                r'math\.(asin|acos|atan)\(([^)]+)\)',
                lambda m: f'math.degrees(math.{m.group(1)}({m.group(2)}))',
                sanitized
            )
        
        try:
            result = eval(sanitized, {'__builtins__': {}, 'math': math, 'pow': pow, 'fabs': abs})
            if isinstance(result, complex):
                return None
            return result
        except Exception as e:
            print(f"Eval error: {e} on {sanitized}")
            return None
    
    # ----- Display -----
    def update_display(self):
        theme = THEMES[self.theme_name]
        
        try:
            val = float(self.current)
            if val > 999999999 or val < -999999999 or ('e' in str(val).lower() and str(val) != 'Error'):
                if val != 0 and math.isfinite(val):
                    self.result_label.text = f'{val:.6e}'
                    self.result_label.font_size = sp(32)
                else:
                    self.result_label.text = self.current
                    self.result_label.font_size = sp(42)
            else:
                self.result_label.text = self._format_num(self.current)
                sz = sp(42)
                if len(self.result_label.text) > 14:
                    sz = sp(32)
                if len(self.result_label.text) > 20:
                    sz = sp(24)
                self.result_label.font_size = sz
        except:
            self.result_label.text = self.current if self.current else 'Error'
            self.result_label.font_size = sp(42)
        
        self.expr_label.text = self.expression
        self.result_label.color = theme['text']
        self.expr_label.color = theme['text_secondary']
        self.mem_label.text = 'M' if self.has_mem else ''
    
    def _format_num(self, s):
        try:
            if s == 'Error' or s is None:
                return 'Error'
            s = str(s)
            if 'e' in s.lower():
                return s
            parts = s.split('.')
            int_part = parts[0]
            if int_part.startswith('-'):
                sign = '-'
                int_part = int_part[1:]
            else:
                sign = ''
            formatted = ''
            for i, ch in enumerate(reversed(int_part)):
                if i > 0 and i % 3 == 0:
                    formatted = ',' + formatted
                formatted = ch + formatted
            if len(parts) > 1:
                return sign + formatted + '.' + parts[1]
            return sign + formatted
        except:
            return s
    
    def _unformat(self, s):
        return s.replace(',', '')
    
    # ----- History -----
    def save_history(self, expr, result):
        self.history.insert(0, {'expr': expr, 'result': result})
        if len(self.history) > 100:
            self.history = self.history[:100]
        self._save_history_disk()
    
    def _save_history_disk(self):
        try:
            path = os.path.join(App.get_running_app().user_data_dir, HISTORY_FILE)
            with open(path, 'w') as f:
                json.dump(self.history, f)
        except:
            pass
    
    def load_history(self):
        try:
            path = os.path.join(App.get_running_app().user_data_dir, HISTORY_FILE)
            if os.path.exists(path):
                with open(path) as f:
                    self.history = json.load(f)
        except:
            self.history = []
    
    def toggle_history(self):
        if self.history_active:
            self.close_history()
        else:
            self.show_history()
    
    def show_history(self):
        if hasattr(self, 'history_popup') and self.history_popup:
            return
        
        theme = THEMES[self.theme_name]
        content = BoxLayout(orientation='vertical', spacing=dp(4))
        content.size_hint = (0.95, 0.85)
        
        header = BoxLayout(size_hint=(1, None), height=dp(44))
        header.add_widget(Label(text='History', font_size=sp(18), bold=True, color=theme['text']))
        clear_btn = Button(
            text='Clear', font_size=sp(14),
            background_color=(0,0,0,0), color=theme['primary'],
            size_hint_x=0.3
        )
        clear_btn.bind(on_press=lambda x: self.clear_history())
        header.add_widget(clear_btn)
        content.add_widget(header)
        
        sv = ScrollView(size_hint=(1, 1))
        hist_layout = BoxLayout(orientation='vertical', size_hint=(1, None), spacing=dp(4))
        hist_layout.bind(minimum_height=hist_layout.setter('height'))
        
        if not self.history:
            hist_layout.add_widget(Label(
                text='No calculations yet',
                font_size=sp(15), color=theme['text_secondary'],
                size_hint=(1, None), height=dp(60)
            ))
        else:
            for h in self.history:
                item = BoxLayout(
                    orientation='vertical',
                    size_hint=(1, None), height=dp(56),
                    padding=[dp(12), dp(6)]
                )
                with item.canvas.before:
                    Color(*theme['btn_num'])
                    RoundedRectangle(pos=item.pos, size=item.size, radius=[dp(8)]*4)
                
                expr_label = Label(
                    text=h['expr'], font_size=sp(13),
                    color=theme['text_secondary'],
                    halign='left', valign='middle',
                    size_hint=(1, 0.45)
                )
                expr_label.bind(size=expr_label.setter('text_size'))
                item.add_widget(expr_label)
                
                res_label = Label(
                    text=h['result'], font_size=sp(18), bold=True,
                    color=theme['text'],
                    halign='left', valign='middle',
                    size_hint=(1, 0.55)
                )
                res_label.bind(size=res_label.setter('text_size'))
                item.add_widget(res_label)
                
                item.bind(on_touch_down=lambda inst, touch, h=h: self._history_tap(inst, touch, h))
                hist_layout.add_widget(item)
        
        sv.add_widget(hist_layout)
        content.add_widget(sv)
        
        close_btn = Button(
            text='Close', font_size=sp(16), bold=True,
            size_hint=(1, None), height=dp(48),
            background_color=theme['btn_eq'],
            color=theme['btn_eq_text'],
            background_normal=''
        )
        close_btn.bind(on_press=lambda x: self.close_history())
        content.add_widget(close_btn)
        
        self.history_popup = Popup(
            title='',
            content=content,
            size_hint=(0.95, 0.85),
            background_color=(0,0,0,0),
            background='',
            separator_height=0,
            auto_dismiss=True
        )
        self.history_popup.bind(on_dismiss=lambda x: setattr(self, 'history_active', False))
        self.history_popup.open()
        self.history_active = True
    
    def _history_tap(self, inst, touch, h):
        if inst.collide_point(*touch.pos):
            try:
                res = h['result'].replace(',', '')
                self.current = res
                self.expression = h['expr'].split(' =')[0]
                self.is_new_entry = True
                self.just_evaluated = False
                self.update_display()
                self.close_history()
            except:
                pass
    
    def close_history(self):
        if hasattr(self, 'history_popup') and self.history_popup:
            self.history_popup.dismiss()
            self.history_popup = None
        self.history_active = False
    
    def clear_history(self):
        self.history = []
        self._save_history_disk()
        self.close_history()
        self.show_toast('History cleared')
    
    # ----- Memory -----
    def show_memory_menu(self):
        theme = THEMES[self.theme_name]
        content = BoxLayout(orientation='vertical', spacing=dp(8), padding=[dp(16)]*4)
        content.size_hint = (0.6, None)
        content.height = dp(280)
        
        with content.canvas.before:
            Color(*theme['surface'])
            RoundedRectangle(pos=content.pos, size=content.size, radius=[dp(16)]*4)
        
        title = Label(
            text='Memory', font_size=sp(18), bold=True,
            color=theme['text'], size_hint=(1, None), height=dp(36)
        )
        content.add_widget(title)
        
        val_label = Label(
            text=f'= {self.memory:.6g}' if self.has_mem else '= (empty)',
            font_size=sp(16), color=theme['text_secondary'],
            size_hint=(1, None), height=dp(30)
        )
        content.add_widget(val_label)
        
        mem_actions = [
            ('MC', lambda: self._mem_clear()),
            ('MR', lambda: self._mem_recall()),
            ('M+', lambda: self._mem_add()),
            ('M−', lambda: self._mem_sub()),
            ('MS', lambda: self._mem_store()),
        ]
        for label, fn in mem_actions:
            btn = Button(
                text=label, font_size=sp(16), bold=True,
                size_hint=(1, None), height=dp(44),
                background_normal='',
                background_color=theme['btn_op'],
                color=theme['btn_op_text']
            )
            btn.bind(on_press=lambda x, f=fn: (f(), popup.dismiss()))
            content.add_widget(btn)
        
        close_btn = Button(
            text='Close', font_size=sp(14),
            size_hint=(1, None), height=dp(36),
            background_normal='', background_color=(0,0,0,0),
            color=theme['text_secondary']
        )
        close_btn.bind(on_press=lambda x: popup.dismiss())
        content.add_widget(close_btn)
        
        popup = Popup(
            title='', content=content,
            size_hint=(0.5, None), height=dp(320),
            background_color=(0,0,0,0.6),
            background='', separator_height=0,
            auto_dismiss=True
        )
        popup.open()
    
    def _mem_clear(self):
        self.memory = 0.0
        self.has_mem = False
        self.update_display()
        self.show_toast('Memory cleared')
    
    def _mem_recall(self):
        if not self.has_mem:
            self.show_toast('Memory empty')
            return
        self.current = str(self.memory)
        self.is_new_entry = True
        self.just_evaluated = False
        self.update_display()
    
    def _mem_add(self):
        try:
            self.memory += float(self.current)
            self.has_mem = True
            self.update_display()
            self.show_toast(f'M+ {self.current}')
        except:
            pass
    
    def _mem_sub(self):
        try:
            self.memory -= float(self.current)
            self.has_mem = True
            self.update_display()
            self.show_toast(f'M− {self.current}')
        except:
            pass
    
    def _mem_store(self):
        try:
            self.memory = float(self.current)
            self.has_mem = True
            self.update_display()
            self.show_toast(f'Stored {self.current}')
        except:
            pass
    
    # ----- Theme -----
    def toggle_theme(self):
        self.theme_name = 'light' if self.theme_name == 'dark' else 'dark'
        self.save_theme()
        self.build_ui()
        self.update_display()
        # Re-apply history if open
        if self.history_active:
            self.close_history()
            Clock.schedule_once(lambda dt: self.show_history(), 0.1)
    
    def save_theme(self):
        try:
            path = os.path.join(App.get_running_app().user_data_dir, THEME_FILE)
            with open(path, 'w') as f:
                json.dump({'theme': self.theme_name}, f)
        except:
            pass
    
    def load_theme(self):
        try:
            path = os.path.join(App.get_running_app().user_data_dir, THEME_FILE)
            if os.path.exists(path):
                with open(path) as f:
                    data = json.load(f)
                    if data.get('theme') in ('dark', 'light'):
                        self.theme_name = data['theme']
        except:
            pass
    
    # ----- Tabs -----
    def switch_tab(self, tab):
        theme = THEMES[self.theme_name]
        if tab == 'basic':
            self.tab_basic.color = theme['text']
            self.tab_sci.color = theme['text_secondary']
            Animation(opacity=1, d=0.15).start(self.basic_grid)
            Animation(opacity=0, d=0.15).start(self.sci_grid)
            self.show_sci = False
        else:
            self.tab_basic.color = theme['text_secondary']
            self.tab_sci.color = theme['text']
            Animation(opacity=0, d=0.15).start(self.basic_grid)
            Animation(opacity=1, d=0.15).start(self.sci_grid)
            self.show_sci = True
    
    # ----- Angle mode -----
    def toggle_angle_mode(self, btn):
        self.is_radian = not self.is_radian
        btn.text = 'RAD' if self.is_radian else 'DEG'
        self.show_toast('RAD mode' if self.is_radian else 'DEG mode')
    
    # ----- Toast -----
    def show_toast(self, msg):
        if hasattr(self, '_toast_label') and self._toast_label:
            try:
                self._toast_label.parent.remove_widget(self._toast_label)
            except:
                pass
        
        theme = THEMES[self.theme_name]
        self._toast_label = Label(
            text=msg, font_size=sp(13),
            color=theme['text'],
            size_hint=(None, None),
            height=dp(36),
            padding=[dp(20), dp(8)]
        )
        self._toast_label.texture_update()
        self._toast_label.width = self._toast_label.texture_size[0] + dp(40)
        
        with self._toast_label.canvas.before:
            Color(*theme['btn_op'])
            RoundedRectangle(
                pos=self._toast_label.pos, size=self._toast_label.size,
                radius=[dp(18)]*4
            )
        
        self._toast_label.pos = (
            self.width / 2 - self._toast_label.width / 2,
            dp(20)
        )
        self.add_widget(self._toast_label)
        
        anim = Animation(y=dp(30), opacity=1, d=0.25)
        anim.bind(on_complete=lambda *a: Clock.schedule_once(
            lambda dt: self._fade_toast(), 1.5
        ))
        anim.start(self._toast_label)
    
    def _fade_toast(self):
        if not hasattr(self, '_toast_label') or not self._toast_label:
            return
        anim = Animation(opacity=0, d=0.3)
        anim.bind(on_complete=lambda *a: self._remove_toast())
        anim.start(self._toast_label)
    
    def _remove_toast(self):
        if hasattr(self, '_toast_label') and self._toast_label:
            try:
                self.remove_widget(self._toast_label)
            except:
                pass
            self._toast_label = None
    
    # ----- Layout helpers -----
    def _update_header_bg(self, inst, val):
        self._header_bg.pos = inst.pos
        self._header_bg.size = inst.size
    
    def _update_display_bg(self, inst, val):
        self._display_bg.pos = inst.pos
        self._display_bg.size = inst.size
    
    def _update_tabs_bg(self, inst, val):
        self._tabs_bg.pos = inst.pos
        self._tabs_bg.size = inst.size


# ---------------------------------------------------------------------------
# App
# ---------------------------------------------------------------------------
class CalcProApp(App):
    def build(self):
        self.title = 'Calc Pro'
        if platform != 'android' and platform != 'ios':
            Window.size = (400, 780)
        # Set up keyboard
        Window.bind(on_key_down=self._on_keyboard)
        
        return CalculatorWidget()
    
    def _on_keyboard(self, window, key, scancode, codepoint, modifier):
        calc = self.root
        if key == 13:  # Enter
            calc.calculate()
            return True
        elif key == 8:  # Backspace
            calc.backspace()
            return True
        elif key == 27:  # Escape
            calc.clear_all()
            return True
        elif 48 <= key <= 57:  # 0-9
            calc.input_digit(chr(key))
            return True
        elif key == 46:  # .
            calc.input_decimal()
            return True
        elif key == 43:  # +
            calc.input_operator('+')
            return True
        elif key == 45:  # -
            calc.input_operator('-')
            return True
        elif key == 42:  # *
            calc.input_operator('*')
            return True
        elif key == 47:  # /
            calc.input_operator('/')
            return True
        elif key == 37:  # %
            calc.input_operator('%')
            return True
        elif key == 94:  # ^
            calc.input_operator('^')
            return True
        elif key == 40:  # (
            calc.input_lparen()
            return True
        elif key == 41:  # )
            calc.input_rparen()
            return True
        return False


if __name__ == '__main__':
    CalcProApp().run()
