
import io
from pathlib import Path
from typing import TextIO
import pytest
import pyweb


@pytest.fixture
def source_path(request, tmp_path) -> [TextIO, pyweb.WebReader, Path]:
    marker = request.node.get_closest_marker("text_name")
    text, name = marker.args
    source = io.StringIO(text)
    path = tmp_path / name
    return source, path



@pytest.fixture
def source_path_incl(request, tmp_path) -> [TextIO, pyweb.WebReader, Path]:
    marker = request.node.get_closest_marker("text_name_incl")
    text, name, incl_text, incl_name = marker.args
    include_path = tmp_path / incl_name
    include_path.write_text(incl_text)
    source = io.StringIO(text)
    path = tmp_path / name
    return source, path

