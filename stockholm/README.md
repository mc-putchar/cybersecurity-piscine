# Stockholm

> A harmless malware.

## ⚠ WARNING ⚠

This program may cause irreversible damage to your system.  
It is intended to be used solely for educational purposes.  
Use at your own risk.  

### Prerequisites

- `bash` `make` `openssl` `base64` `awk`
- Recommended: `docker compose` OR virtual machine

## Usage

Ensure the program is executable:

```bash
chmod +x stockholm
```

Take files hostage: `./stockholm`  

Unlock files: `./stockholm -r <key>`  

The key to unlock the files is stored in `private.pem`.  
Make sure to keep the private key safe. Without it, the files are lost forever*.  
<sub>*probably</sub>

## Containerized

To run the program in a container, using `docker compose`,  
ensure you have a directory named `infection` in the root of the project.  
Place files you'd like to encrypt in the `infection` directory.  

Then run:

```bash
make me cry
```
