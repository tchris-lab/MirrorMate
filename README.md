<img src="./docs/logo.png"> 

---

## Overview

**MirrorMate** is an open-source command-line tool to easily switch between the fastest or preferred mirrors for popular package managers and system repositories. Whether you're in a country with slow access to global package registries or want to use trusted local mirrors, MirrorMate simplifies the process by dynamically configuring mirrors for:

- Python's PyPI  
- Node.js NPM  
- Docker registries  
- Go module proxy  
- Debian/Ubuntu APT repositories

---

## Why MirrorMate?

- **Fast & Reliable**: Use mirrors closer to your location to speed up downloads.  
- **Unified Interface**: Manage all your package mirrors from one tool.  
- **Easy to Extend**: Add new mirrors by editing a simple list — no coding required.  
- **Backup & Restore**: Automatically backs up your current settings and allows quick restoration.  
- **Interactive & User-friendly**: Uses a text menu interface (whiptail) for easy navigation.

---

## Use Cases

- Developers in regions with restricted or slow access to official package registries.  
- Teams that want to standardize their mirror configuration across environments.  
- Anyone wanting to quickly test different mirrors for speed or availability.  
- System administrators managing multiple machines and want consistent mirror setups.

---

## Installation

### From apt repositories

```bash
sudo apt-get install mirrormate
```

### Manually

```bash
# Clone repository
git clone https://github.com/free-programmers/MirrorMate.git
cd MirrorMate

# Make executable
chmod +x script.sh

# Run script with sudo
sudo ./script.sh
```

### Requires:

- Bash shell  
- `whiptail` installed (the script will try to install it if missing)  
- sudo privileges

---

## Usage

Run the script and follow the menu prompts:

1. Select a category (Python, Node.js, Docker, Go, APT)  
2. Choose your preferred mirror from the list  
3. Confirm to apply the mirror  
4. Optionally restore previous settings anytime from the menu  

---

## Adding New Mirrors

To add a new mirror, simply edit the `MIRRORS` array in the script:

```bash
MIRRORS+=(
    "Python|PyPI - New Mirror Name|https://new.mirror.url/simple"
    "APT|Ubuntu 22.04 - New Mirror|deb https://new.mirror.url/ubuntu/ jammy main restricted universe multiverse"
)
```

Each mirror entry has the format:

```
Category|Display Name|Mirror URL or source list content
```

---

## Contributing

Contributions are welcome! Here's how you can help:

- **Add new mirrors:** Submit mirror URLs for your region or provider.  
- **Fix bugs:** Report or fix issues on GitHub.  
- **Improve UI:** Suggest or implement UI improvements or better UX.  
- **Enhance features:** Add new package managers or mirror types.

### To contribute:

1. Fork the repository  
2. Create a new branch (`git checkout -b feature-name`)  
3. Make your changes  
4. Test thoroughly  
5. Submit a pull request with a clear description

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## Contact & Support

For questions, feature requests, or issues, please open an issue on GitHub:  
[https://github.com/free-programmers/MirrorMate/issues](https://github.com/free-programmers/MirrorMate/issues)
