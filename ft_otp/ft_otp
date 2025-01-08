#!/usr/bin/env python3
# Version: 0.0.42
import argparse
import base64
import time
import string
from hashlib import sha1
import random

# BONUS
import qrcode
from os import environ, path
environ['KIVY_NO_CONSOLELOG'] = "1"
environ['KIVY_NO_ARGS'] = "1"
from kivy.app import App
from kivy.core.window import Window
from kivy.clock import Clock
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.progressbar import ProgressBar
from kivy.properties import ObjectProperty
from kivy.uix.button import Button
from kivy.uix.label import Label


TIME_STEP = 30
DIGITS = 6
XOR_KEY = "*~42 is the answer to life, the universe, and everything!"
DEBUG = False

def hexrandom():
	return ''.join(random.choice(string.hexdigits) for _ in range(64))

def xor_encrypt(key):
	encrypted_key = ''.join(chr(ord(c) ^ ord(XOR_KEY[i % len(XOR_KEY)])) for i, c in enumerate(key))
	return encrypted_key

def encrypt_key(key_file):
	try:
		key = key_file.read().strip().lower()
		if (DEBUG):
			print(f'Key: {key}')
	except:
		print("Error: Unable to read key file")
		raise SystemExit(1)
	if any(c not in string.hexdigits for c in key):
		print("Error: Invalid key format. Must be hexadecimal")
		raise SystemExit(1)
	if len(key) < 64:
		print("Error: Key must be at least 64 characters")
		raise SystemExit(1)
	secret_key = xor_encrypt(key)
	try:
		secret_key = base64.b32encode(secret_key.encode())
	except:
		print("Error: Unable to encode key")
		raise SystemExit(1)
	try:
		with open('ft_otp.key', 'wb') as f:
			f.write(secret_key)
		if (DEBUG):
			print(f'Generated secret key: {secret_key}')
	except:
		print("Error: Unable to write to file")
		raise SystemExit(1)

def decrypt_key(key):
	try:
		decoded_key = base64.b32decode(key).decode('utf-8')
	except:
		print("Error: Unable to decode key")
		raise SystemExit(1)
	decrypted_key = xor_encrypt(decoded_key)
	return decrypted_key

def hmac_sha1(key, counter_bytes):
	if len(key) < 64:
		key += b'\x00' * (64 - len(key))
	ipad = bytes([x ^ 0x36 for x in key])
	opad = bytes([x ^ 0x5C for x in key])
	inner = sha1(ipad + counter_bytes).digest()
	outer = sha1(opad + inner).digest()
	return outer

def truncate(hmac_sha1):
	if len(hmac_sha1) < 20:
		print("Error: Invalid HMAC-SHA1 length")
		raise SystemExit(1)
	offset = hmac_sha1[19] & 0x0F
	p = hmac_sha1[offset:offset+4]
	bincode = (p[0] & 0x7F) << 24 | (p[1] & 0xFF) << 16 | (p[2] & 0xFF) << 8 | (p[3] & 0xFF)
	return bincode

def generate_otp(key_file):
	try:
		key = key_file.read()
		if (DEBUG):
			print(f'Key: {key.decode()}')
	except:
		print("Error: Unable to read key file")
		raise SystemExit(1)
	key = decrypt_key(key)
	if (DEBUG):
		print(f'Key: {key}')
	time_now = int(time.time())
	counter = int(time_now // TIME_STEP)
	counter_bytes = counter.to_bytes(8, byteorder='big')
	bincode = truncate(hmac_sha1(bytes.fromhex(key), counter_bytes))
	otp = bincode % 10 ** DIGITS
	return str(otp).zfill(DIGITS)

def generate_qr_code():
	issuer = 'ft_otp'
	username = 'ohteepee@42.fr'
	try:
		with open('ft_otp.key', 'rb') as f:
			secret_key = bytes.fromhex(decrypt_key(f.read()))
	except:
		print("Error: Unable to read key file. Generate it first using -g option")
		raise SystemExit(1)
	if (DEBUG):
		print(f'Secret before: {secret_key.decode("utf-8", errors="ignore")}')
	secret_key = base64.b32encode(secret_key).decode('utf-8')
	uri = f'otpauth://totp/{issuer}:{username}?secret={secret_key}'
	if (DEBUG):
		print(f'Secret after: {secret_key}')
		print(f'URI: {uri}')
	qr = qrcode.QRCode(
		version=1,
		error_correction=qrcode.constants.ERROR_CORRECT_L,
		box_size=10,
		border=1,
	)
	qr.add_data(uri)
	qr.print_ascii(invert=True)


class MainWindow(BoxLayout):
	progress_bar = ObjectProperty(None)
	label = ObjectProperty(None)

	def __init__(self, **kwargs):
		super().__init__(**kwargs)

	def generate_otp(self):
		with open('ft_otp.key', 'rb') as f:
			otp = generate_otp(f)
		self.label.text = ' '.join([otp[i:i+3] for i in range(0, len(otp), 3)])
		self.start_time = time.time() // TIME_STEP * TIME_STEP
		Clock.schedule_interval(self.update_timer, 1 / 10)

	def reset_timer(self):
		self.progress_bar.value = 0
		Clock.unschedule(self.update_timer)
		self.label.text = "--- ---"

	def update_timer(self, dt):
		elapsed_time = (time.time() - self.start_time) % TIME_STEP
		remaining_time = TIME_STEP - elapsed_time
		self.progress_bar.value = (remaining_time / TIME_STEP) * 100
		if remaining_time < 0.1:
			self.reset_timer()

class MyButton(Button):
	pass
class MyLabel(Label):
	pass

class ft_otpApp(App):
	def build(self):
		win = MainWindow()
		try:
			if not path.exists('ft_otp.key'):
				with open('ft_otp.key', 'wb') as f:
					f.write(base64.b32encode(xor_encrypt(hexrandom()).encode()))
		except:
			print("Error: Unable to write to file")
			raise SystemExit(1)
		return win

def ft_otp():
	parser = argparse.ArgumentParser(
		prog="ft_otp",
		description="42 Cybersecurity Piscine - Time-based One Time Password (TOTP)",
		epilog="Nothing ever lasts forever..."
	)
	group = parser.add_mutually_exclusive_group(required=True)
	group.add_argument("-g", type=argparse.FileType("r"), metavar="<HEX FILE>", help="load and encrypt hexadecimal secret key (at least 64 characters)")
	group.add_argument("-k", type=argparse.FileType("rb"), metavar="<KEY FILE>", help="generate OTP using encrypted key file")
	group.add_argument("--qr", action="store_true", help="generate QR code URL")
	group.add_argument("--x", action="store_true", help="generate random hexadecimal string and store it in key.hex")
	group.add_argument("--gui", action="store_true", help="Run the GUI")
	args = parser.parse_args()
	if args.g:
		encrypt_key(args.g)
	elif args.k:
		print(generate_otp(args.k))
	elif args.qr:
		generate_qr_code()
	elif args.x:
		try:
			with open('key.hex', 'w') as f:
				f.write(hexrandom())
		except:
			print("Error: Unable to write to file")
			raise SystemExit(1)
	elif args.gui:
		Window.size = (360, 180)
		ft_otpApp().run()
	else:
		parser.print_help()

if __name__ == '__main__':
	ft_otp()
