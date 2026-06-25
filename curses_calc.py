#!/usr/bin/env python3
"""Calc Pro - Terminal-based calculator using curses"""

import curses
import math
import json
import os

HISTORY_FILE = os.path.expanduser('~/.calc_history')

# ── Theme colors ──────────────────────────────────────────────
THEMES = {
    'dark': {
        'bg': 0, 'fg': 7, 'title': 3, 'expr': 8, 'result': 7,
        'btn_num': 4, 'btn_op': 3, 'btn_eq': 5, 'btn_clear': 6,
        'display_bg': 4, 'btn_fg': 7,
        'mem': 3, 'tab_active': 2, 'tab_inactive': 8,
    },
    'light': {
        'bg': 7, 'fg': 0, 'title': 5, 'expr': 8, 'result': 0,
        'btn_num': 4, 'btn_op': 6, 'btn_eq': 5, 'btn_clear': 6,
        'display_bg': 4, 'btn_fg': 7,
        'mem': 5, 'tab_active': 2, 'tab_inactive': 8,
    },
}

# ── Layout ────────────────────────────────────────────────────
BASIC_BTNS = [
    ('AC', 1, 'clear'), ('⌫', 1, 'backspace'), ('%', 2, 'op'), ('÷', 2, 'op'),
    ('7', 0, 'num'), ('8', 0, 'num'), ('9', 0, 'num'), ('×', 2, 'op'),
    ('4', 0, 'num'), ('5', 0, 'num'), ('6', 0, 'num'), ('−', 2, 'op'),
    ('1', 0, 'num'), ('2', 0, 'num'), ('3', 0, 'num'), ('+', 2, 'op'),
    ('0', 0, 'num'), ('.', 0, 'num'), ('±', 1, 'func'), ('=', 3, 'eq'),
]

SCI_BTNS = [
    ('sin', 1, 'func'), ('cos', 1, 'func'), ('tan', 1, 'func'), ('log', 1, 'func'), ('ln', 1, 'func'),
    ('sin⁻¹', 1, 'func'), ('cos⁻¹', 1, 'func'), ('tan⁻¹', 1, 'func'), ('√', 1, 'func'), ('∛', 1, 'func'),
    ('x²', 1, 'func'), ('x³', 1, 'func'), ('xʸ', 1, 'func'), ('x!', 1, 'func'), ('1/x', 1, 'func'),
    ('π', 1, 'func'), ('e', 1, 'func'), ('eˣ', 1, 'func'), ('10ˣ', 1, 'func'), ('|x|', 1, 'func'),
    ('AC', 1, 'clear'), ('⌫', 1, 'clear'), ('%', 2, 'op'), ('÷', 2, 'op'), ('×', 2, 'op'),
    ('7', 0, 'num'), ('8', 0, 'num'), ('9', 0, 'num'), ('−', 2, 'op'), ('+', 2, 'op'),
    ('4', 0, 'num'), ('5', 0, 'num'), ('6', 0, 'num'), ('(', 1, 'func'), (')', 1, 'func'),
    ('1', 0, 'num'), ('2', 0, 'num'), ('3', 0, 'num'), ('0', 0, 'num'), ('.', 0, 'num'),
    ('±', 1, 'func'), ('=', 3, 'eq'),
]


class Calculator:
    def __init__(self):
        self.expression = ''
        self.current = '0'
        self.memory = 0.0
        self.has_mem = False
        self.history = []
        self.is_new_entry = True
        self.just_evaluated = False
        self.paren_count = 0
        self.last_answer = None
        self.show_sci = False
        self.mode = 'basic'
        self.angle_mode = 'DEG'
        self.is_radian = False
        self.theme_name = 'dark'
        self.load_history()
        self.load_theme()

    def load_history(self):
        try:
            if os.path.exists(HISTORY_FILE):
                with open(HISTORY_FILE) as f:
                    self.history = json.load(f)
        except:
            self.history = []

    def save_history(self):
        try:
            with open(HISTORY_FILE, 'w') as f:
                json.dump(self.history[:100], f)
        except:
            pass

    def load_theme(self):
        try:
            p = os.path.expanduser('~/.calc_theme')
            if os.path.exists(p):
                with open(p) as f:
                    d = json.load(f)
                    if 'theme' in d:
                        self.theme_name = d['theme']
        except:
            pass

    def save_theme(self):
        try:
            with open(os.path.expanduser('~/.calc_theme'), 'w') as f:
                json.dump({'theme': self.theme_name}, f)
        except:
            pass

    def toggle_theme(self):
        self.theme_name = 'light' if self.theme_name == 'dark' else 'dark'
        self.save_theme()

    def toggle_angle(self):
        self.is_radian = not self.is_radian
        self.angle_mode = 'RAD' if self.is_radian else 'DEG'

    def input_digit(self, d):
        if self.just_evaluated:
            self.expression = ''
            self.current = '0'
            self.just_evaluated = False
        if self.is_new_entry:
            self.current = d
            self.is_new_entry = False
        else:
            if self.current == '0':
                self.current = d
            elif len(self.current) < 16:
                self.current += d

    def input_decimal(self):
        if self.just_evaluated:
            self.expression = ''
            self.current = '0.'
            self.just_evaluated = False
            self.is_new_entry = False
            return
        if self.is_new_entry:
            self.current = '0.'
            self.is_new_entry = False
            return
        if '.' not in self.current:
            self.current += '.'

    def input_operator(self, op):
        self.just_evaluated = False
        self.is_new_entry = False
        disp_op = {'+': '+', '-': '−', '*': '×', '/': '÷', '^': '^', '%': '%'}.get(op, op)

        expr = self.expression
        if self.current != '0' and not self.is_new_entry:
            if expr and expr[-1] == ')':
                expr += ' ' + disp_op
            else:
                expr += self._unfmt(self.current)

        last = expr[-1] if expr else ''
        if last in '+-×÷^' or last == '(' or expr == '':
            if last in '+-×÷^':
                expr = expr[:-1].strip()

        if op == '%':
            try:
                v = float(self.current) / 100
                self.current = str(v)
                expr += self._unfmt(self.current)
            except:
                self.current = 'Error'
            self.expression = expr + '%'
            self.is_new_entry = True
            return

        expr += ' ' + disp_op + ' '
        self.expression = expr
        self.current = '0'
        self.is_new_entry = True

    def input_func(self, fn):
        self.just_evaluated = False
        expr = self.expression
        cur = self._unfmt(self.current)

        try:
            v = float(self.current)
        except:
            return

        mapping = {
            'square': ('²', v * v),
            'cube': ('³', v * v * v),
            'sqrt': ('√(...)', math.sqrt(v) if v >= 0 else None),
            'cbrt': ('∛(...)', math.cbrt(v)),
            'reciprocal': ('1/(...)', 1.0 / v if v != 0 else None),
            'sin': ('sin(...)', self._trig(math.sin, v)),
            'cos': ('cos(...)', self._trig(math.cos, v)),
            'tan': ('tan(...)', self._trig(math.tan, v)),
            'asin': ('asin(...)', self._atrig(math.asin, v)),
            'acos': ('acos(...)', self._atrig(math.acos, v)),
            'atan': ('atan(...)', self._atrig(math.atan, v)),
            'log': ('log(...)', math.log10(v) if v > 0 else None),
            'ln': ('ln(...)', math.log(v) if v > 0 else None),
            'exp': ('exp(...)', math.exp(v)),
            'tenx': ('10ˣ(...)', math.pow(10, v)),
            'abs': ('|...|', abs(v)),
        }

        if fn in mapping:
            display, result = mapping[fn]
            if result is None:
                return
            # factorial
            expr += display.replace('...', cur) if '...' in display else cur + display
            self.expression = expr
            self.current = str(result)
            self.is_new_entry = True
        elif fn == 'factorial':
            if v < 0 or v != int(v):
                return
            f = 1
            for i in range(2, int(v) + 1):
                f *= i
            expr += cur + '!'
            self.expression = expr
            self.current = str(f)
            self.is_new_entry = True
        elif fn == 'pi':
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
        elif fn == 'negate':
            self.current = str(-v)

    def _trig(self, fn, v):
        return fn(math.radians(v)) if not self.is_radian else fn(v)

    def _atrig(self, fn, v):
        r = fn(v)
        return math.degrees(r) if not self.is_radian else r

    def input_lparen(self):
        if self.just_evaluated:
            self.expression = ''
            self.current = '0'
            self.just_evaluated = False
        self.expression += '('
        self.paren_count += 1

    def input_rparen(self):
        if self.paren_count <= 0:
            return
        self.expression += ')'
        self.paren_count -= 1

    def clear(self):
        self.expression = ''
        self.current = '0'
        self.is_new_entry = True
        self.just_evaluated = False
        self.paren_count = 0

    def backspace(self):
        if self.just_evaluated:
            self.clear()
            return
        if self.is_new_entry:
            return
        if len(self.current) > 1:
            self.current = self.current[:-1]
        else:
            self.current = '0'
            self.is_new_entry = True

    def negate(self):
        try:
            self.current = str(-float(self.current))
        except:
            pass

    def calculate(self):
        expr = self.expression
        if not expr:
            self.current = '0'
            self.is_new_entry = True
            return

        oc = expr.count('(')
        cc = expr.count(')')
        while cc < oc:
            expr += ')'
            cc += 1

        last = expr[-1] if expr else ''
        if last in '+-×÷^(' or last == '' or last == ' ':
            return

        if not self.is_new_entry and self.current != '0':
            if last != ')':
                expr += self._unfmt(self.current)

        result = self._evaluate(expr)
        if result is None or not math.isfinite(result):
            self.current = 'Error'
            self.expression = expr
            return

        rs = str(round(result, 12))
        self.history.insert(0, {'expr': expr + ' =', 'result': self._fmt(rs)})
        self.save_history()
        self.expression = expr
        self.current = rs
        self.is_new_entry = True
        self.just_evaluated = True
        self.last_answer = rs

    def _evaluate(self, s):
        s = s.replace('×', '*').replace('÷', '/').replace('−', '-')
        s = s.replace('π', str(math.pi)).replace('²', '**2').replace('³', '**3')
        s = s.replace('^', '**')
        # e constant -> math.e, but protect exp
        s = s.replace('exp', '@EXP@')
        s = s.replace('e', str(math.e))
        s = s.replace('@EXP@', 'math.exp')
        # Insert * between number and paren
        import re
        s = re.sub(r'(\d)\(', r'\1*(', s)
        s = re.sub(r'\)\(', r')*(', s)
        s = re.sub(r'\)(\d)', r')*\1', s)

        funcs = {
            'sin': 'math.sin', 'cos': 'math.cos', 'tan': 'math.tan',
            'asin': 'math.asin', 'acos': 'math.acos', 'atan': 'math.atan',
            'log': 'math.log10', 'ln': 'math.log',
            'sqrt': 'math.sqrt', 'cbrt': 'math.cbrt',
            'abs': 'fabs', 'tenx': 'pow10',
        }
        for k, v in funcs.items():
            s = re.sub(r'(?<!\w)' + k + r'\(', v + '(', s)

        if not self.is_radian:
            for f in ('sin', 'cos', 'tan'):
                s = re.sub(
                    f'math\\.{f}\\((.*?)\\)',
                    lambda m, f=f: f'math.{f}(math.radians({m.group(1)}))',
                    s
                )
            for f in ('asin', 'acos', 'atan'):
                s = re.sub(
                    f'math\\.{f}\\((.*?)\\)',
                    lambda m, f=f: f'math.degrees(math.{f}({m.group(1)}))',
                    s
                )

        try:
            def pow10(x): return math.pow(10, x)
            r = eval(s, {'__builtins__': {}, 'math': math, 'pow': pow, 'fabs': abs, 'pow10': pow10})
            return r if not isinstance(r, complex) else None
        except:
            return None

    def _fmt(self, s):
        try:
            s = str(s)
            if 'e' in s.lower():
                return s
            parts = s.split('.')
            intp = parts[0]
            sign = ''
            if intp.startswith('-'):
                sign = '-'
                intp = intp[1:]
            fmt = ''
            for i, ch in enumerate(reversed(intp)):
                if i and i % 3 == 0:
                    fmt = ',' + fmt
                fmt = ch + fmt
            return sign + fmt + ('.' + parts[1] if len(parts) > 1 else '')
        except:
            return s

    def _unfmt(self, s):
        return s.replace(',', '')

    # ── Memory ──
    def mem_clear(self): self.memory = 0.0; self.has_mem = False
    def mem_recall(self):
        if not self.has_mem:
            return False
        self.current = str(self.memory)
        self.is_new_entry = True
        self.just_evaluated = False
        return True
    def mem_add(self):
        try:
            self.memory += float(self.current)
            self.has_mem = True
        except:
            pass
    def mem_sub(self):
        try:
            self.memory -= float(self.current)
            self.has_mem = True
        except:
            pass
    def mem_store(self):
        try:
            self.memory = float(self.current)
            self.has_mem = True
        except:
            pass

    def get_result_text(self):
        try:
            v = float(self.current)
            if v > 999999999 or v < -999999999 or 'e' in str(v).lower():
                return f'{v:.6e}' if math.isfinite(v) else self.current
            return self._fmt(self.current)
        except:
            return self.current if self.current else 'Error'


# ── UI ────────────────────────────────────────────────────────
def draw_app(stdscr, calc):
    curses.use_default_colors()
    curses.curs_set(0)
    stdscr.nodelay(1)
    stdscr.timeout(100)

    # Color init
    for i in range(9):
        curses.init_pair(i, i, -1)
    # Custom pairs
    curses.init_pair(10, curses.COLOR_CYAN, -1)        # title
    curses.init_pair(11, curses.COLOR_WHITE, -1)        # fg
    curses.init_pair(12, curses.COLOR_YELLOW, -1)       # accent
    curses.init_pair(13, curses.COLOR_MAGENTA, -1)      # secondary
    curses.init_pair(14, curses.COLOR_GREEN, -1)        # success/tab
    curses.init_pair(15, curses.COLOR_BLACK, -1)        # dark
    curses.init_pair(16, curses.COLOR_BLUE, -1)         # blue
    curses.init_pair(17, curses.COLOR_RED, -1)          # red
    curses.init_pair(18, curses.COLOR_WHITE, curses.COLOR_BLUE)   # btn display
    curses.init_pair(19, curses.COLOR_WHITE, curses.COLOR_CYAN)   # btn num
    curses.init_pair(20, curses.COLOR_WHITE, curses.COLOR_MAGENTA) # btn clear
    curses.init_pair(21, curses.COLOR_WHITE, curses.COLOR_YELLOW)  # btn eq
    curses.init_pair(22, curses.COLOR_BLACK, curses.COLOR_WHITE)   # btn op light
    curses.init_pair(23, curses.COLOR_WHITE, curses.COLOR_BLACK)   # btn fg

    theme = THEMES[calc.theme_name]

    # Colors based on theme
    if calc.theme_name == 'dark':
        BG = 15; FG = 11; TITLE = 10; EXPR = 8; RESULT = 11
        BTN_NUM = 19; BTN_OP = 22; BTN_EQ = 21; BTN_CLR = 20
        DISP_BG = 18; MEM_COL = 12
        TAB_ACT = 14; TAB_INACT = 8
    else:
        BG = 11; FG = 15; TITLE = 13; EXPR = 8; RESULT = 15
        BTN_NUM = 19; BTN_OP = 22; BTN_EQ = 21; BTN_CLR = 20
        DISP_BG = 18; MEM_COL = 13
        TAB_ACT = 14; TAB_INACT = 8

    def cprint(y, x, text, col=FG, bold=False, rev=False):
        attr = curses.color_pair(col) | (curses.A_BOLD if bold else 0) | (curses.A_REVERSE if rev else 0)
        try:
            stdscr.addstr(y, x, text, attr)
        except:
            pass

    def draw_buttons(buttons, start_y, cols):
        for i, (label, ty, action) in enumerate(buttons):
            row = start_y + i // cols
            col_x = 2 + (i % cols) * (btn_w + 1)
            if col_x + btn_w > max_x:
                continue
            if ty == 0:
                c = BTN_NUM
            elif ty == 1:
                c = BTN_CLR
            elif ty == 2:
                c = BTN_OP
            elif ty == 3:
                c = BTN_EQ
            else:
                c = BTN_NUM
            # Special: 0 spans
            span = 2 if label == '0' and cols == 4 else 1
            if row >= max_y - 1:
                continue
            stdscr.attron(curses.color_pair(c))
            stdscr.addstr(row, col_x, ' ' * (btn_w * span - 1))
            stdscr.attroff(curses.color_pair(c))

            c = FG if ty in (1, 3) else (BG if calc.theme_name == 'light' else FG)
            if ty == 0:
                cf = BG
            elif ty == 1:
                cf = FG
            elif ty == 2:
                cf = FG if calc.theme_name == 'dark' else BG
            else:
                cf = FG
            cprint(row, col_x + (btn_w * span - len(label)) // 2, label, cf, bold=True)

    max_y, max_x = stdscr.getmaxyx()
    if max_y < 24 or max_x < 20:
        stdscr.clear()
        cprint(0, 0, "Terminal too small. Need at least 24x20.", 17)
        stdscr.refresh()
        return False

    btn_w = max(5, (max_x - 3) // 5 if calc.show_sci else (max_x - 2) // 4)
    if btn_w > 8:
        btn_w = 8

    # ── Draw ──
    stdscr.clear()
    stdscr.bkgd(' ', curses.color_pair(BG))

    # Header
    cprint(0, 0, f" Calc Pro ", TITLE, bold=True)
    cprint(0, max_x - 14, f"[{calc.angle_mode}]", MEM_COL)
    cprint(0, max_x - 8, f" {'☀️' if calc.theme_name == 'light' else '🌙'} ", 12)
    cprint(0, max_x - 5, f" 📋 ", 11)

    # Memory indicator
    if calc.has_mem:
        cprint(1, max_x - 4, "M", MEM_COL, bold=True)

    # Display
    disp_y = 2
    disp_h = 5
    for dy in range(disp_h):
        stdscr.attron(curses.color_pair(DISP_BG))
        stdscr.addstr(disp_y + dy, 0, ' ' * max_x)
        stdscr.attroff(curses.color_pair(DISP_BG))

    # Expression
    expr_text = calc.expression
    if len(expr_text) > max_x - 2:
        expr_text = '...' + expr_text[-(max_x - 5):]
    cprint(disp_y + 1, 2, expr_text, EXPR)

    # Result
    res = calc.get_result_text()
    res_x = max_x - len(res) - 2
    if res_x < 2:
        res = res[-max_x + 4]
        res_x = 2
    cprint(disp_y + 3, res_x, res, RESULT, bold=True)

    # Tab bar
    tab_y = disp_y + disp_h
    tab_sel = ' SCI ' if calc.show_sci else ' BASIC '
    tab_other = ' BASIC ' if calc.show_sci else ' SCI '
    cprint(tab_y, 1, f'[{tab_sel}]', TAB_ACT, bold=True, rev=True)
    cprint(tab_y, 1 + len(tab_sel) + 3, f'[{tab_other}]', TAB_INACT)

    # Buttons
    btns = SCI_BTNS if calc.show_sci else BASIC_BTNS
    cols = 5 if calc.show_sci else 4
    btn_start = tab_y + 2

    # Draw grid
    visible_btns = []
    for label, ty, action in btns:
        visible_btns.append((label, ty, action))

    for i, (label, ty, action) in enumerate(visible_btns):
        row = btn_start + i // cols
        col_x = 2 + (i % cols) * (btn_w + 1)
        if row >= max_y - 1 or col_x + btn_w > max_x:
            continue
        if ty == 0:
            cf = 19
        elif ty == 1:
            cf = 20
        elif ty == 2:
            cf = 22
        else:
            cf = 21
        stdscr.attron(curses.color_pair(cf))
        stdscr.addstr(row, col_x, ' ' * btn_w)
        stdscr.attroff(curses.color_pair(cf))
        tx = col_x + (btn_w - len(label)) // 2
        cprint(row, tx, label, FG if ty in (1,3) else BG, bold=True)

    # Status bar
    cprint(max_y - 1, 0, f" M:{'Y' if calc.has_mem else 'N'} | Hist:{len(calc.history)} | ?=help ", 8)

    stdscr.refresh()
    return True


def run_curses(stdscr, calc):
    key_map = {
        ord('0'): '0', ord('1'): '1', ord('2'): '2', ord('3'): '3',
        ord('4'): '4', ord('5'): '5', ord('6'): '6', ord('7'): '7',
        ord('8'): '8', ord('9'): '9',
        ord('.'): '.', ord('+'): '+', ord('-'): '-',
        ord('*'): '*', ord('/'): '/', ord('%'): '%',
        ord('^'): '^', ord('('): '(', ord(')'): ')',
        ord('\n'): '=', ord('\r'): '=',
    }

    toast_msg = ''
    toast_timer = 0
    show_help = False

    while True:
        if not draw_app(stdscr, calc):
            stdscr.refresh()
            continue

        # Toast
        if toast_msg and toast_timer > 0:
            toast_timer -= 1
            try:
                stdscr.attron(curses.A_REVERSE)
                stdscr.addstr(1, 2, f' {toast_msg} ')
                stdscr.attroff(curses.A_REVERSE)
                stdscr.refresh()
            except:
                pass
            if toast_timer <= 0:
                toast_msg = ''

        # Help overlay
        if show_help:
            helptext = [
                "── Calc Pro Help ──",
                "",
                "Keys: 0-9 . + - * / % ^ ( ) Enter",
                "Backspace = delete, Esc = clear",
                "Tab = toggle mode, t = theme",
                "a = angle mode, . = decimal",
                "h = history, m = memory menu",
                "s = sin, c = cos, t = tan",
                "q = quit",
                "",
                "Memory: MC MR M+ M- MS",
                "",
                "Press any key to close",
            ]
            h = len(helptext) + 2
            w = 44
            sy = max(0, (stdscr.getmaxyx()[0] - h) // 2)
            sx = max(0, (stdscr.getmaxyx()[1] - w) // 2)
            for i, line in enumerate(helptext):
                cprint(sy + i, sx, f' {line:<{w-2}} ', 18, bold=i == 0)
            stdscr.refresh()
            stdscr.getch()
            show_help = False
            continue

        k = stdscr.getch()
        if k == -1:
            continue

        # Quit
        if k == ord('q') or k == ord('Q'):
            break

        # Help
        if k == ord('?'):
            show_help = True
            continue

        # Tab - toggle mode
        if k == 9 or k == ord('\t'):
            calc.show_sci = not calc.show_sci
            continue

        # Theme
        if k == ord('t') or k == ord('T'):
            calc.toggle_theme()
            toast_msg = f'Themed: {calc.theme_name}'
            toast_timer = 20
            continue

        # Angle
        if k == ord('a') or k == ord('A'):
            calc.toggle_angle()
            toast_msg = f'Mode: {calc.angle_mode}'
            toast_timer = 20
            continue

        # History
        if k == ord('h') or k == ord('H'):
            if calc.history:
                # Show last 10
                text = "── History (last 10) ──"
                items = []
                for h in calc.history[:10]:
                    items.append(f"  {h['expr']} {h['result']}")
                lines = [text] + items + ["", "Press 'c' to clear, any key to close"]
                h = len(lines) + 2
                w = 46
                sy = max(0, (stdscr.getmaxyx()[0] - h) // 2)
                sx = max(0, (stdscr.getmaxyx()[1] - w) // 2)
                stdscr.clear()
                for i, line in enumerate(lines):
                    cprint(sy + i, sx, f' {line:<{w-2}} ', 18, bold=i == 0)
                stdscr.refresh()
                k2 = stdscr.getch()
                if k2 == ord('c') or k2 == ord('C'):
                    calc.history = []
                    calc.save_history()
                    toast_msg = 'History cleared'
                    toast_timer = 20
            else:
                toast_msg = 'No history'
                toast_timer = 20
            continue

        # Memory menu
        if k == ord('m') or k == ord('M'):
            lines = [
                "── Memory Menu ──",
                f"  Value: {calc.memory:.6g} {'(set)' if calc.has_mem else '(empty)'}",
                "",
                "  MC  - Clear memory",
                "  MR  - Recall",
                "  M+  - Add to memory",
                "  M-  - Subtract from memory",
                "  MS  - Store to memory",
                "",
                "Press key: c r + - s",
            ]
            h = len(lines) + 2
            w = 36
            sy = max(0, (stdscr.getmaxyx()[0] - h) // 2)
            sx = max(0, (stdscr.getmaxyx()[1] - w) // 2)
            stdscr.clear()
            for i, line in enumerate(lines):
                cprint(sy + i, sx, f' {line:<{w-2}} ', 18, bold=i == 0)
            stdscr.refresh()
            k2 = stdscr.getch()
            if k2 == ord('c'): calc.mem_clear(); toast_msg = 'Memory cleared'
            elif k2 == ord('r'):
                if calc.mem_recall():
                    toast_msg = f'Recalled {calc.memory}'
                else:
                    toast_msg = 'Memory empty'
            elif k2 == ord('+'): calc.mem_add(); toast_msg = 'M+'
            elif k2 == ord('-'): calc.mem_sub(); toast_msg = 'M-'
            elif k2 == ord('s'): calc.mem_store(); toast_msg = f'Stored {calc.current}'
            toast_timer = 20
            continue

        # Backspace
        if k in (curses.KEY_BACKSPACE, 127, 8):
            calc.backspace()
            continue

        # Escape - clear
        if k == 27:
            calc.clear()
            continue

        # Digits
        if k >= ord('0') and k <= ord('9'):
            calc.input_digit(chr(k))
            continue

        if k in key_map:
            v = key_map[k]
            if v == '=':
                calc.calculate()
            elif v == '(':
                calc.input_lparen()
            elif v == ')':
                calc.input_rparen()
            elif v in ('+', '-', '*', '/', '%', '^'):
                calc.input_operator(v)
            elif v == '.':
                calc.input_decimal()
            continue

        # Scientific function keys
        sci_keys = {
            ord('s'): 'sin', ord('c'): 'cos', ord('n'): 'tan',
        }
        if k == ord('!'):
            calc.input_func('factorial')
        elif k == ord('p'):
            calc.input_func('pi')
        elif k == ord('e'):
            calc.input_func('econst')
        elif k == ord('l'):
            calc.input_func('log')
        elif k == ord('r'):
            calc.input_func('sqrt')
        elif k == ord('2'):
            calc.input_func('square')
        elif k == ord('3'):
            calc.input_func('cube')

    return True


def main():
    calc = Calculator()
    curses.wrapper(lambda stdscr: run_curses(stdscr, calc))


if __name__ == '__main__':
    main()
