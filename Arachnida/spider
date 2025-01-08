#!/usr/bin/env python3
import aiohttp
import asyncio
import requests
import click
import os
from re import findall
from urllib.parse import urljoin, urlparse
from urllib.robotparser import RobotFileParser
from html.parser import HTMLParser
from collections import deque
from textual.app import App, ComposeResult
from textual.containers import Horizontal, Vertical
from textual.color import Gradient
from textual.widgets import Header, Static, ProgressBar, RichLog, Footer, Label, Digits

IMG_EXTS = ('.jpg', '.jpeg', '.png', '.gif', '.bmp')
MAX_CONCURRENT_REQUESTS = 10
DOWNLOAD_TIMEOUT = 10

verboso = False
sem = asyncio.Semaphore(MAX_CONCURRENT_REQUESTS)

class SpiderParser(HTMLParser):
    def __init__(self, base_url):
        super().__init__()
        self.links = set()
        self.imgs = set()
        self.base_url = base_url

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'a' and 'href' in attrs:
            href = urljoin(self.base_url, attrs['href'])
            self.links.add(href)
        elif tag == 'img' and 'src' in attrs:
            src = urljoin(self.base_url, attrs['src'])
            self.imgs.add(src)
        elif tag == 'link' and attrs.get('rel') == 'stylesheet' and 'href' in attrs:
            href = urljoin(self.base_url, attrs['href'])
            self.links.add(href)
        elif tag == 'script' and 'src' in attrs:
            src = urljoin(self.base_url, attrs['src'])
            self.links.add(src)


def extract_imgs_from_css(css, base_url):
    urls = findall(r'url\((?:\'|"|)(.*?)(?:\'|"|)\)', css)
    img_urls = set()
    for url in urls:
        if any(url.lower().endswith(ext) for ext in IMG_EXTS):
            joined_url = urljoin(base_url, url)
            img_urls.add(joined_url)
    return img_urls

def crawl(start_url, max_depth):
    global verboso
    visited = set()
    imgs = set()
    que = deque()
    que.append((start_url, 0))
    parsed_start = urlparse(start_url)
    domain = parsed_start.netloc

    robo_parser = RobotFileParser()
    robo_url = urljoin(start_url, "/robots.txt")
    try:
        robo_parser.set_url(robo_url)
        robo_parser.read()
    except Exception as e:
        print(f'Error: loading robots.txt: {e}')

    while que:
        currl, depth = que.popleft()
        if (currl in visited or depth > max_depth):
            continue
        visited.add(currl)
        if not robo_parser.can_fetch('*', currl):
            print(f'Blocked by robots.txt: {currl}')
            continue
        if verboso:
            print(f'D[{depth}] Crawling: {currl}')
        try:
            r = requests.get(currl, timeout=4.2)
            r.raise_for_status()
            content = r.headers.get('Content-Type', '')
            if 'text/html' in content:
                parser = SpiderParser(currl)
                parser.feed(r.text)
                for img in parser.imgs:
                    if img.lower().endswith(IMG_EXTS):
                        imgs.add(img)
                for link in parser.links:
                    link_parsed = urlparse(link)
                    if link_parsed.netloc == domain:
                        que.append((link, depth + 1))
            elif 'text/css' in content:
                imgs.update(extract_imgs_from_css(r.text, currl))

        except (requests.RequestException) as e:
            print(f'Error occured fetching {currl}: {e}')

    return imgs

def download_img(url, pathname):
    global verboso
    relpath = urlparse(url).path
    dir = pathname + os.path.split(relpath)[0]
    try:
        r = requests.get(url, stream=True)
        r.raise_for_status()
        os.makedirs(dir, exist_ok=True)
        filename = os.path.join(dir, url.split("/")[-1])
        with open(filename, "wb") as f:
            for chunk in r.iter_content(chunk_size=1024):
                f.write(chunk)
        if verboso:
            print(f'Downloaded: {url}')
    except (requests.RequestException) as e:
        print(f'An error occured: {e}')

async def fetch_rate_limited(url, session, text_log):
    async with sem:
        return await fetch_url(url, session, text_log)

async def fetch_url(url, session, text_log):
    global verboso
    if text_log:
        text_log.write(f'Crawling: {url}')
    elif verboso:
        print(f'Crawling: {url}')
    try:
        async with session.get(url, timeout=4.2) as rep:
            if rep.status == 200:
                return await rep.text(), rep.headers.get('Content-Type', ''), url
    except Exception as e:
        if text_log:
            text_log.write(f'Error: fetch {url}: {e}')
        else:
            print(f'Error: fetch {url}: {e}')
    return None, None, url

async def proc_url(url, session, domain, visited, que, depth, imgs, robo_parser, text_log):
    if not robo_parser.can_fetch('*', url):
        if not text_log:
            print(f'Blocked by robots.txt: {url}')
        else:
            text_log.write(f'Blocked by robots.txt: {url}')
        return
    content, content_type, currl = await fetch_rate_limited(url, session, text_log)
    if not content:
        return
    visited.add(currl)
    if 'text/html' in content_type:
        parser = SpiderParser(currl)
        parser.feed(content)
        imgs.update(img for img in parser.imgs if img.lower().endswith(IMG_EXTS))
        for link in parser.links:
            link_parsed = urlparse(link)
            if link_parsed.netloc == domain and link not in visited:
                que.append((link, depth + 1))
    elif 'text/css' in content_type:
        imgs.update(extract_imgs_from_css(content, currl))

async def dl_img(url, session, pathname, progress_bar, text_log):
    global verboso
    async with sem:
        try:
            dir = pathname + os.path.split(urlparse(url).path)[0]
            os.makedirs(dir, exist_ok=True)
            filename = url.split("/")[-1]
            file = os.path.join(dir, filename)
            async with session.get(url, timeout=DOWNLOAD_TIMEOUT) as rep:
                if rep.status == 200:
                    with open(file, "wb") as f:
                        f.write(await rep.read())
                    if text_log:
                        text_log.write(f'Downloaded: {filename}')
                    elif verboso:
                        print(f'Downloaded: {filename}')
                    if progress_bar:
                        progress_bar.advance(1)
        except Exception as e:
            if text_log:
                text_log.write(f'Failed to download {url}: {e}')
            else:
                print(f'Failed to download {url}: {e}')

async def crawl_async(start_url, max_depth, path, text_log=None, crawl_bar=None, dl_bar=None):
    visited = set()
    imgs = set()
    que = deque()
    que.append((start_url, 0))
    parsed_start = urlparse(start_url)
    domain = parsed_start.netloc
    robo_parser = RobotFileParser()
    robo_url = urljoin(start_url, "/robots.txt")
    try:
        robo_parser.set_url(robo_url)
        robo_parser.read()
    except Exception as e:
        if text_log is not None:
            text_log.write(f'Error: loading robots.txt: {e}')
        else:
            print(f'Error: loading robots.txt: {e}')
    async with aiohttp.ClientSession() as session:
        if crawl_bar is not None:
            crawl_bar.update(total=max_depth)
        while que:
            currl, depth = que.popleft()
            if currl in visited:
                continue
            if depth > max_depth:
                continue
            await proc_url(currl, session, domain, visited, que, depth, imgs, robo_parser, text_log)
            if crawl_bar is not None:
                crawl_bar.update(progress=depth)
        if text_log is not None:
            text_log.write(f'Crawl completed. Found {len(imgs)} images.')
        if dl_bar is not None:
            dl_bar.update(total=len(imgs))
            dl_bar.loading = False
        dl_tasks = [dl_img(img, session, path, dl_bar, text_log) for img in imgs]
        await asyncio.gather(*dl_tasks)
        if text_log is not None:
            text_log.write(f'Downloads completed.')
    return imgs


class SpiderApp(App):
    def __init__(self, start_url, max_depth, out_path):
        super().__init__()
        self.start_url = start_url
        self.max_depth = max_depth
        self.out_path = out_path

    TITLE = "42 Spider"
    SUB_TITLE = "Web crawler and image downloader Arachnida"
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
    RichLog {
        align: center middle;
        border: hkey teal;
        padding: 1;
    }
    ProgressBar {
        align: center middle;
    }
    Static {
        padding: 1;
    }
    """
    def compose(self) -> ComposeResult:
        gradient = Gradient.from_colors(
            "#881177",
            "#aa3355",
            "#cc6666",
            "#ee9944",
            "#eedd00",
            "#99dd55",
            "#44dd88",
            "#22ccbb",
            "#00bbcc",
            "#0099cc",
            "#3366bb",
            "#663399",
        )
        yield Header(show_clock=True)
        with Vertical():
            yield Static("Crawl:")
            yield ProgressBar(show_percentage=True, show_eta=False, name="crawl_progress", id="crawl_progress", gradient=gradient)
            yield Static("Download:")
            yield ProgressBar(show_eta=False, name="download_progress", id="download_progress")
            yield RichLog(wrap=True, name="log")
        yield Footer()

    async def on_mount(self) -> None:
        self.text_log = self.query_one("RichLog")
        self.crawl_progress = self.query_one("#crawl_progress")
        self.download_progress = self.query_one("#download_progress")
        self.download_progress.loading = True
        asyncio.create_task(self.run_spider())

    async def run_spider(self):
        await crawl_async(
            self.start_url,
            self.max_depth,
            self.out_path,
            self.text_log,
            self.crawl_progress,
            self.download_progress
        )
        self.sub_title = f'Done scraping {self.start_url}'


@click.command()
@click.option('-u', '--pretty_ui', is_flag=True, default=False)
@click.option('-a', '--asynchronous', is_flag=True, default=False)
@click.option('-v', '--verbose', is_flag=True, default=False)
@click.option('-r', '--recursive', is_flag=True, default=False)
@click.option('-l', '--depth', default=5, show_default=True)
@click.option('-p', '--path', default='./data', show_default=True)
@click.argument('url')
def spider(url, recursive, depth, path, asynchronous, verbose, pretty_ui):
    global verboso
    verboso = verbose
    if pretty_ui:
        SpiderApp(url, depth, path).run()
        return
    if verboso:
        print(f'URL: {url}')
        print(f'Path: {path}')
        print(f'Depth: {depth}')
    if not recursive:
        depth = 0
    spidey_sensed = []
    if asynchronous:
        spidey_sensed += asyncio.run(crawl_async(url, depth, path))
        if verboso:
            print(f'Found {len(spidey_sensed)} image files.')
    else:
        spidey_sensed += crawl(url, depth)
    if url.endswith((IMG_EXTS)):
        spidey_sensed.append(url)
    if spidey_sensed is None:
        print("No images found")
        return
    if not asynchronous:
        if verboso:
            print(f'Found {len(spidey_sensed)} image files.')
        for img in spidey_sensed:
            download_img(img, path)

if __name__ == "__main__":
    spider()
