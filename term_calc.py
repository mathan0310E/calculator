#!/usr/bin/env python3
"""Calc Pro - Interactive Terminal Calculator"""

import math
import os
import sys
import json
import readline
import atexit

HIST_FILE = os.path.expanduser('~/.calc_hist')

theme = 'dark'
memory = 0.0
has_mem = False
history = []
angle_mode = 'DEG'
is_radian = False
current = '0'
expression = ''
is_new_entry = True
just_evaluated = False
paren_count = 0
last_answer = None
show_sci = False

RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
MAGENTA = '\033[95m'
CYAN = '\033[96m'
WHITE = '\033[97m'
BOLD = '\033[1m'
DIM = '\033[2m'
RESET = '\033[0m'
GRAY = '\033[90m'
BG_BLUE = '\033[44m'
BG_CYAN = '\033[46m'
BG_MAGENTA = '\033[45m'
BG_YELLOW = '\033[43m'
REVERSE = '\033[7m'
CLR = '\033[2J\033[H'

def load_state():
    global history, theme
    try:
        if os.path.exists(HIST_FILE):
            with open(HIST_FILE) as f:
                d = json.load(f)
                history = d.get('history', [])
                theme = d.get('theme', 'dark')
    except:
        pass

def save_state():
    try:
        with open(HIST_FILE, 'w') as f:
            json.dump({'history': history[:100], 'theme': theme}, f)
    except:
        pass

load_state()

def fmt(s):
    try:
        s = str(s)
        if 'e' in s.lower(): return s
        parts = s.split('.')
        ip = parts[0]
        sign = ''
        if ip.startswith('-'): sign = '-'; ip = ip[1:]
        r = ''
        for i, ch in enumerate(reversed(ip)):
            if i and i % 3 == 0: r = ',' + r
            r = ch + r
        return sign + r + ('.' + parts[1] if len(parts) > 1 else '')
    except: return s

def unfmt(s): return s.replace(',', '')

def C_HEADER(): return f'{BOLD}{CYAN}'
def C_TITLE(): return f'{BOLD}{MAGENTA}'
def C_EXPR(): return f'{DIM}{GRAY}'
def C_RESULT(): return f'{BOLD}{WHITE}'
def C_MEM(): return f'{YELLOW}'
def C_ERR(): return f'{RED}'
def C_ACCENT(): return f'{YELLOW}'
def C_GREEN(): return f'{GREEN}'
def RES(): return f'{RESET}'
def c(s, col): return col + s + RESET

def clear_screen(): print(CLR, end='')

def draw():
    clear_screen()
    try:
        w = os.get_terminal_size().columns
    except:
        w = 72
    w = min(w, 80)

    # Title bar
    title = "Calc Pro"
    mode_str = f"[{angle_mode}]"
    theme_icon = '☀️' if theme == 'light' else '🌙'
    mem_str = ' M' if has_mem else ''
    title_line = f" {c(title, C_TITLE())}  {c(mode_str, C_MEM())}   {theme_icon}  {c('📋', C_ACCENT())}{c(mem_str, C_MEM())}"
    print(f"{'─'*w}")
    print(title_line)
    print(f"{'─'*w}")

    # Display
    print(f"{BG_BLUE}{' ' * w}{RESET}")
    ex = expression
    if len(ex) > w - 4: ex = '...' + ex[-(w - 7):]
    print(f"{BG_BLUE}  {C_EXPR()}{ex:<{w-4}}{RESET}{BG_BLUE}{RESET}")
    res = current
    try:
        v = float(current)
        if v > 999999999 or v < -999999999 or 'e' in str(v).lower():
            res = f'{v:.6e}' if math.isfinite(v) else current
        else:
            res = fmt(current)
    except: res = current
    pad = w - len(res) - 3
    print(f"{BG_BLUE}  {' ' * pad}{C_RESULT()}{res}{RESET}{BG_BLUE}  {RESET}")
    print(f"{BG_BLUE}{' ' * w}{RESET}")
    print(f"{'─'*w}")

    # Tab bar
    tabs = f" {c('[BASIC]', C_GREEN() + REVERSE) if not show_sci else c(' BASIC ', C_EXPR())}   {c('[SCIENTIFIC]', C_GREEN() + REVERSE) if show_sci else c(' SCIENTIFIC ', C_EXPR())} "
    print(tabs)
    print(f"{'─'*w}")

    # Button layout display
    print()
    bcol = f"{DIM}{WHITE}"
    if not show_sci:
        print(f"  {c('AC', RED+'BOLD')}  {c('⌫', RED)}  {c('%', YELLOW)}  {c('÷', YELLOW)}")
        print(f"  {c('7', CYAN)}  {c('8', CYAN)}  {c('9', CYAN)}  {c('×', YELLOW)}")
        print(f"  {c('4', CYAN)}  {c('5', CYAN)}  {c('6', CYAN)}  {c('−', YELLOW)}")
        print(f"  {c('1', CYAN)}  {c('2', CYAN)}  {c('3', CYAN)}  {c('+', YELLOW)}")
        print(f"  {c('0', CYAN)}  {c('.', CYAN)}  {c('±', MAGENTA)}  {c('=', GREEN)}")
    else:
        print(f"  {c('sin', MAGENTA)} {c('cos', MAGENTA)} {c('tan', MAGENTA)} {c('log', MAGENTA)} {c('ln', MAGENTA)}")
        print(f"  {c('√', MAGENTA)}  {c('x²', MAGENTA)} {c('x³', MAGENTA)} {c('xʸ', YELLOW)} {c('x!', MAGENTA)}")
        print(f"  {c('π', MAGENTA)}  {c('e', MAGENTA)}  {c('eˣ', MAGENTA)} {c('10ˣ', MAGENTA)}{c('|x|', MAGENTA)}")
        print(f"  {c('AC', RED)}   {c('⌫', RED)}   {c('%', YELLOW)}  {c('÷', YELLOW)}  {c('×', YELLOW)}")
        print(f"  {c('7', CYAN)}   {c('8', CYAN)}   {c('9', CYAN)}   {c('−', YELLOW)}  {c('+', YELLOW)}")
        print(f"  {c('4', CYAN)}   {c('5', CYAN)}   {c('6', CYAN)}   {c('(', MAGENTA)}  {c(')', MAGENTA)}")
        print(f"  {c('1', CYAN)}   {c('2', CYAN)}   {c('3', CYAN)}   {c('0', CYAN)}   {c('.', CYAN)}")
        print(f"  {c('±', MAGENTA)} {'':>5}  {c('=', GREEN)}")

    print(f"{'─'*w}")
    print(f" {c('Keys:', GRAY)} digits . + - * / % ^ ( ) Enter  |  {c('Backspace', RED)}={c('⌫', RED)}  {c('Esc', RED)}={c('AC', RED)}")
    print(f" {c('Tab', CYAN)}=mode  {c('t', CYAN)}=theme  {c('a', CYAN)}=angle  {c('h', CYAN)}=history  {c('m', CYAN)}=memory  {c('?', CYAN)}=help  {c('q', CYAN)}=quit")
    print(f"{'─'*w}")

    # History snippet
    if history:
        last = history[0]
        print(f" {DIM}Last: {last['expr']} {last['result']}{RESET}")

def evaluate(expr):
    s = expr
    s = s.replace('×', '*').replace('÷', '/').replace('−', '-')
    s = s.replace('π', str(math.pi)).replace('²', '**2').replace('³', '**3')
    s = s.replace('^', '**')
    s = s.replace('exp', '@EXP@')
    s = s.replace('e', str(math.e))
    s = s.replace('@EXP@', 'math.exp')
    import re
    s = re.sub(r'(\d)\(', r'\1*(', s); s = re.sub(r'\)\(', r')*(', s); s = re.sub(r'\)(\d)', r')*\1', s)
    for f, g in [('sin','math.sin'),('cos','math.cos'),('tan','math.tan'),
                  ('asin','math.asin'),('acos','math.acos'),('atan','math.atan'),
                  ('log','math.log10'),('ln','math.log'),('sqrt','math.sqrt'),
                  ('cbrt','math.cbrt'),('abs','fabs'),('tenx','pow10')]:
        s = re.sub(r'(?<!\w)'+f+r'\(', g+'(', s)
    if not is_radian:
        for f in ('sin','cos','tan'):
            s = re.sub(f'math\\.{f}\\((.*?)\\)', lambda m, f=f: f'math.{f}(math.radians({m.group(1)}))', s)
        for f in ('asin','acos','atan'):
            s = re.sub(f'math\\.{f}\\((.*?)\\)', lambda m, f=f: f'math.degrees(math.{f}({m.group(1)}))', s)
    try:
        def pow10(x): return math.pow(10,x)
        r = eval(s, {'__builtins__':{},'math':math,'pow':pow,'fabs':abs,'pow10':pow10})
        return r if not isinstance(r, complex) else None
    except:
        return None

def calculate():
    global expression, current, is_new_entry, just_evaluated, paren_count
    ex = expression
    if not ex: return
    oc = ex.count('('); cc = ex.count(')')
    while cc < oc: ex += ')'; cc += 1
    last = ex[-1] if ex else ''
    if last in '+-×÷^(' or last == '' or last == ' ': return
    if not is_new_entry and current != '0' and last != ')':
        ex += unfmt(current)
    result = evaluate(ex)
    if result is None or not math.isfinite(result):
        current = 'Error'; expression = ex; return
    rs = str(round(result, 12))
    history.insert(0, {'expr': ex + ' =', 'result': fmt(rs)})
    save_state()
    expression = ex; current = rs; is_new_entry = True; just_evaluated = True

def show_help():
    clear_screen()
    print(f"{BOLD}{CYAN}Calc Pro Help{RESET}")
    print(f"{'─'*50}")
    print(f" {BOLD}Input:{RESET}    Type expressions directly (e.g. 2+3*4)")
    print(f" {BOLD}Functions:{RESET} sin, cos, tan, asin, acos, atan, log, ln")
    print(f"               sqrt, cbrt, abs, exp, tenx")
    print(f" {BOLD}Constants:{RESET}  pi, e  (type them in expression)")
    print(f" {BOLD}Operators:{RESET}  +  -  *  /  %  ^  (  )")
    print(f" {BOLD}Keys:{RESET}")
    print(f"   Tab        - Toggle mode (Basic / Scientific)")
    print(f"   t          - Toggle theme")
    print(f"   a          - Toggle angle mode (DEG/RAD)")
    print(f"   h          - Show history")
    print(f"   m          - Memory menu")
    print(f"   ?          - This help")
    print(f"   q          - Quit")
    print(f"   Backspace  - Delete last digit")
    print(f"   Escape     - Clear all")
    print(f"   Enter      - Calculate")
    print(f"   Sin/Cos/Tan: type sin(30), cos(45), tan(0.5)")
    print(f"   Factorial : x! (postfix)")
    print(f"   Square    : x² or x**2")
    print(f"   Cube      : x³ or x**3")
    print(f"   Root      : sqrt(x) or cbrt(x)")
    print(f"{'─'*50}")
    input(f"{DIM}Press Enter to continue...{RESET}")

def show_history():
    global history
    clear_screen()
    print(f"{BOLD}{CYAN}History{RESET}")
    print(f"{'─'*50}")
    if not history:
        print(f" {DIM}No calculations yet{RESET}")
    else:
        for i, h in enumerate(history[:20], 1):
            print(f" {i:2d}. {h['expr']} {c(h['result'], C_RESULT())}")
    print(f"{'─'*50}")
    print(f" {DIM}Enter a number to restore, 'c' to clear, Enter to close{RESET}")
    r = input("> ").strip()
    if r == 'c' or r == 'C':
        history = []
        save_state()
        print(f" {RED}History cleared{RESET}")
        input(f"{DIM}Press Enter...{RESET}")
    elif r.isdigit():
        idx = int(r) - 1
        if 0 <= idx < len(history):
            h = history[idx]
            global current, expression, is_new_entry, just_evaluated
            current = h['result'].replace(',', '')
            expression = h['expr'].split(' =')[0]
            is_new_entry = True; just_evaluated = False

def show_memory():
    global memory, has_mem
    clear_screen()
    print(f"{BOLD}{YELLOW}Memory{RESET}")
    print(f"{'─'*30}")
    print(f" Value: {c(str(memory) if has_mem else '(empty)', C_RESULT())}")
    print(f"{'─'*30}")
    print(f" {BOLD}MC{RESET} - Clear    {BOLD}MR{RESET} - Recall")
    print(f" {BOLD}M+{RESET} - Add      {BOLD}M-{RESET} - Subtract")
    print(f" {BOLD}MS{RESET} - Store")
    print(f"{'─'*30}")
    r = input("Command (mc/mr/m+/m-/ms/Enter): ").strip().lower()
    if r == 'mc': memory = 0.0; has_mem = False; print(f" {GREEN}Cleared{RESET}")
    elif r == 'mr':
        if has_mem:
            global current, is_new_entry, just_evaluated
            current = str(memory); is_new_entry = True; just_evaluated = False
            print(f" {GREEN}Recalled{RESET}")
        else: print(f" {RED}Empty{RESET}")
    elif r == 'm+':
        try: memory += float(current); has_mem = True; print(f" {GREEN}M+ {current}{RESET}")
        except: print(f" {RED}Invalid{RESET}")
    elif r == 'm-':
        try: memory -= float(current); has_mem = True; print(f" {GREEN}M- {current}{RESET}")
        except: print(f" {RED}Invalid{RESET}")
    elif r == 'ms':
        try: memory = float(current); has_mem = True; print(f" {GREEN}Stored {current}{RESET}")
        except: print(f" {RED}Invalid{RESET}")
    if r:
        save_state()
        input(f"{DIM}Press Enter...{RESET}")


# ── Main Loop ────────────────────────────────────────────────
print(CLR, end='')
print(f"{C_TITLE()}Calc Pro{RESET} - {DIM}Interactive Terminal Calculator{RESET}")
print(f"{DIM}Type ? for help, q to quit{RESET}")
print()

while True:
    draw()
    try:
        cmd = input(f"\n{C_GREEN()}expr>{RESET} ").strip()
    except (EOFError, KeyboardInterrupt):
        print()
        break

    if not cmd:
        continue

    if cmd == 'q':
        break
    if cmd == '?':
        show_help()
        continue
    if cmd == 't' or cmd == 'T':
        theme = 'light' if theme == 'dark' else 'dark'
        save_state()
        continue
    if cmd == 'a' or cmd == 'A':
        is_radian = not is_radian
        angle_mode = 'RAD' if is_radian else 'DEG'
        continue
    if cmd == 'h' or cmd == 'H':
        show_history()
        continue
    if cmd == 'm' or cmd == 'M':
        show_memory()
        continue
    if cmd in ('s', 'S'):
        show_sci = not show_sci
        continue
    if cmd == '\t':
        show_sci = not show_sci
        continue

    # Check if it's a raw expression
    if any(op in cmd for op in '+-*/%^()' if op != ' ') or any(f in cmd for f in
       ['sin','cos','tan','log','ln','sqrt','cbrt','abs','exp','pi','e']):
        # Full expression mode
        expression = cmd
        current = '0'
        is_new_entry = True
        just_evaluated = False
        paren_count = 0
        calculate()
        if current != 'Error':
            print(f"  = {c(fmt(current), C_RESULT())}")
        else:
            print(f"  {c('Error', RED)}")
        input(f"{DIM}Press Enter...{RESET}")
        continue

    # Simple command processing
    if cmd == 'c' or cmd == 'C':
        expression = ''; current = '0'; is_new_entry = True; just_evaluated = False; paren_count = 0
        continue

    # Try to handle as button presses
    import re
    if re.match(r'^[\d.+\-*/%^()=]+$', cmd):
        for ch in cmd:
            if ch in '0123456789': 
                if just_evaluated: expression = ''; current = '0'; just_evaluated = False
                if is_new_entry: current = ch; is_new_entry = False
                else:
                    if current == '0': current = ch
                    elif len(current) < 16: current += ch
            elif ch == '.':
                if just_evaluated: expression = ''; current = '0.'; just_evaluated = False; is_new_entry = False
                elif is_new_entry: current = '0.'; is_new_entry = False
                elif '.' not in current: current += '.'
            elif ch == '=':
                calculate()
            elif ch in '+-*/%^':
                just_evaluated = False; is_new_entry = False
                disp = {'+':'+','-':'−','*':'×','/':'÷','%':'%','^':'^'}[ch]
                ex = expression
                if current != '0' and not is_new_entry:
                    ex += unfmt(current) if not (ex and ex[-1] == ')') else ''
                last = ex[-1] if ex else ''
                if last in '+-×÷^' or last == '(' or not ex:
                    if last in '+-×÷^': ex = ex[:-1].strip()
                if ch == '%':
                    try:
                        v = float(current)/100; current = str(v); ex += unfmt(current)
                    except: current = 'Error'
                    expression = ex + '%'; is_new_entry = True
                else:
                    ex += ' ' + disp + ' '
                    expression = ex; current = '0'; is_new_entry = True
            elif ch == '(':
                if just_evaluated: expression = ''; current = '0'; just_evaluated = False
                expression += '('; paren_count += 1
            elif ch == ')':
                if paren_count > 0: expression += ')'; paren_count -= 1
        continue

    # Function commands
    if cmd in ('sin','cos','tan','asin','acos','atan','log','ln','sqrt','cbrt','abs','exp','tenx'):
        import re as _re
        just_evaluated = False
        v = float(current) if current != 'Error' else 0
        
        fns = {
            'sin': lambda x: math.sin(math.radians(x)) if not is_radian else math.sin(x),
            'cos': lambda x: math.cos(math.radians(x)) if not is_radian else math.cos(x),
            'tan': lambda x: math.tan(math.radians(x)) if not is_radian else math.tan(x),
            'asin': lambda x: math.degrees(math.asin(x)) if not is_radian else math.asin(x),
            'acos': lambda x: math.degrees(math.acos(x)) if not is_radian else math.acos(x),
            'atan': lambda x: math.degrees(math.atan(x)) if not is_radian else math.atan(x),
            'log': lambda x: math.log10(x) if x > 0 else None,
            'ln': lambda x: math.log(x) if x > 0 else None,
            'sqrt': lambda x: math.sqrt(x) if x >= 0 else None,
            'cbrt': math.cbrt,
            'abs': abs,
            'exp': math.exp,
            'tenx': lambda x: math.pow(10, x),
        }
        
        r = fns[cmd](v) if cmd in fns else None
        if r is None or not math.isfinite(r):
            print(f" {RED}Error{RESET}")
            input(f"{DIM}Press Enter...{RESET}")
            continue
        expression += f'{cmd}({unfmt(current)})'
        current = str(r)
        is_new_entry = True
        continue
    
    if cmd in ('pi', 'π'):
        expression += ('π' if not (expression and current != '0' and not is_new_entry) else f'{unfmt(current)}^π')
        expression = expression.replace('^π', 'π')  # fix
        current = str(math.pi)
        is_new_entry = True
        continue
    
    if cmd == 'square' or cmd == '²':
        v = float(current); r = v * v
        expression += unfmt(current) + '²'
        current = str(r); is_new_entry = True
        continue
    
    if cmd == 'cube' or cmd == '³':
        v = float(current); r = v * v * v
        expression += unfmt(current) + '³'
        current = str(r); is_new_entry = True
        continue
    
    if cmd == 'factorial' or cmd == '!':
        v = float(current)
        if v < 0 or v != int(v):
            print(f" {RED}Integer >= 0 only{RESET}")
            input(f"{DIM}Press Enter...{RESET}")
            continue
        f = 1
        for i in range(2, int(v)+1): f *= i
        expression += unfmt(current) + '!'
        current = str(f); is_new_entry = True
        continue
    
    if cmd in ('±', 'negate', 'n'):
        current = str(-float(current)); continue
    
    if cmd == '1/x' or cmd == 'reciprocal':
        v = float(current)
        if v == 0:
            print(f" {RED}Cannot divide by zero{RESET}")
            input(f"{DIM}Press Enter...{RESET}")
            continue
        expression += f'1/({unfmt(current)})'
        current = str(1/v); is_new_entry = True
        continue
    
    # If nothing matched, try evaluating as expression
    expression = cmd
    current = '0'
    is_new_entry = True
    just_evaluated = False
    calculate()
    if current != 'Error':
        print(f"  = {c(fmt(current), C_RESULT())}")
    else:
        print(f"  {c('Error', RED)}")
    input(f"{DIM}Press Enter...{RESET}")

print(f"\n{DIM}Goodbye!{RESET}")
save_state()
