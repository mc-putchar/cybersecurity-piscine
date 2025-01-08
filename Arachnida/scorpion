#!/usr/bin/env python3
import os
import time
import click
from pathlib import Path
from PIL import Image, PngImagePlugin, JpegImagePlugin
from PIL.ExifTags import TAGS
from textual.app import App, ComposeResult
from textual.containers import Horizontal, Vertical
from textual.widgets import Header, Footer, Button, DataTable, Collapsible, Static, Label, Pretty

IMG_EXTS = ('.jpg', '.jpeg', '.png', '.gif', '.bmp')

def parse_metadata(filepath):
    if not os.path.exists(filepath):
        return None, f'File {filepath} does not exist.'
    
    try:
        with Image.open(filepath) as img:
            metadata = {}
            if isinstance(img, PngImagePlugin.PngImageFile):
                metadata.update(img.info)
            elif isinstance(img, JpegImagePlugin.JpegImageFile):
                exif_data = img.getexif()
                if exif_data:
                    metadata.update({TAGS.get(tag, tag): value for tag, value in exif_data.items()})
            return metadata, None
    except Exception as e:
        return None, str(e)

def modify_metadata(filepath, key, value):
    try:
        with Image.open(filepath) as img:
            if isinstance(img, PngImagePlugin.PngImageFile):
                img.info[key] = value
                img.save(filepath)
            elif isinstance(img, JpegImagePlugin.JpegImageFile):
                exif_data = img.info.get("exif")
                if exif_data:
                    img.save(filepath, exif=exif_data)
            return True, None
    except Exception as e:
        return False, str(e)

def delete_metadata(filepath):
    try:
        with Image.open(filepath) as img:
            img.save(filepath, exif=b"")
        return True, None
    except Exception as e:
        return False, str(e)

@click.group()
def scorpion():
    """42 Scorpion - image metadata tool 🦂"""
    pass

@scorpion.command()
@click.argument('files', nargs=-1, required=True)
def display(files):
    """Display metadata of an image."""
    for file in files:
        _, ext = os.path.splitext(file)
        if ext in IMG_EXTS:
            metadata, error = parse_metadata(file)
        else:
            error = f'File extension {ext} not supported'
        if error:
            click.echo(f'Error: {error}')
        else:
            click.echo(f'FILE: {file}')
            for key, value in metadata.items():
                click.echo(f'{key}: {value}')

@scorpion.command()
@click.argument('filepath', type=click.Path(exists=True))
@click.option('--key', required=True, help='Metadata key to modify.')
@click.option('--value', required=True, help='New value for the metadata.')
def modify(filepath, key, value):
    """Modify a specific metadata key of an image."""
    success, error = modify_metadata(filepath, key, value)
    if success:
        click.echo("Successfully modified image metadata.")
    else:
        click.echo(f'Error: {error}')

@scorpion.command()
@click.argument('filepath', type=click.Path(exists=True))
def delete(filepath):
    """Delete all metadata of an image."""
    success, error = delete_metadata(filepath)
    if success:
        click.echo("Successfully deleted image metadata.")
    else:
        click.echo(f'Error: {error}')

class ScorpionApp(App):
    TITLE = "42 Scorpion"
    SUB_TITLE = "Image metadata tool Arachnida"
    CSS = """
    Screen {
        align: center middle;
        padding: 1;
    }
    Vertical {
        border: double purple;
        padding: 1;
        width: auto;
        height: auto;
    }
    Collapsible {
        align: center middle;
        border: solid teal;
    }
    Label {
        align: center middle;
        padding: 1;
    }
    #filename {
        color: aqua 90%;
    }
    """
    def __init__(self, filepaths, **kwargs):
        super().__init__(**kwargs)
        self.filepaths = filepaths

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Vertical(id="file-container")
        yield Footer()

    async def on_mount(self) -> None:
        container = self.query_one("#file-container")
        for filepath in self.filepaths:
            filename = os.path.basename(filepath)
            created_time = time.ctime(os.path.getctime(filepath))
            modified_time = time.ctime(os.path.getmtime(filepath))
            metadata, error = parse_metadata(filepath)

            try:
                file_metadata = ""
                if error:
                    file_metadata += f'Error: {error}\n'
                else:
                    file_metadata += "\n".join(f'{key}: {value}' for key, value in metadata.items())
                label_metadata = Pretty(metadata)
                delete_btn = Button(f'Delete Metadata for {filename}', variant="error", disabled=False if len(metadata) > 0 else True)
                delete_btn.metadata = {"filepath": filepath}
                file_collapsible = Collapsible(
                    label_metadata, delete_btn,
                    title=f'Metadata ({len(metadata)})',
                    id=f'collapsible-{Path(filename).stem}',
                    disabled=False if len(metadata) > 0 else True
                )
                container.mount(file_collapsible)
                file_name_static = Static(f'Filename: {filename}\n', id="filename")
                file_info_static = Static(f'Created: {created_time}\nModified: {modified_time}\n')
                file_collapsible.mount(file_name_static)
                file_collapsible.mount(file_info_static)
            except Exception as e:
                click.echo(f'Error: {e}')

    def on_button_pressed(self, event: Button.Pressed) -> None:
        filepath = event.button.metadata["filepath"]
        success, error = delete_metadata(filepath)
        if success:
            event.button.label = "Metadata Deleted"
            event.button.disabled = True
        else:
            even.button.label = f'Error: {error}'

@scorpion.command()
@click.argument('filepaths', nargs=-1, type=click.Path(exists=True))
def display_gui(filepaths):
    """Display metadata of an image in a GUI."""
    if not filepaths:
        click.echo("No files provided.")
        return
    ScorpionApp(filepaths=filepaths).run()

if __name__ == "__main__":
    scorpion()
