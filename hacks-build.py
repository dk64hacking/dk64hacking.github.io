import os
import json

def fileRefToURL(file_ref: str, hack_name: str) -> str:
    """Converts a file reference to a url."""
    if file_ref.startswith("https://") or file_ref.startswith("http://") or file_ref.startswith("www."):
        return file_ref
    return f"./hack-data/{hack_name}/{file_ref}"

def getHackInfoHTML(head: str, value: str, have_strong_head: bool=True, have_strong_value: bool=False, is_table_head: bool=False) -> str:
    cell_text = "th" if is_table_head else "td"
    lines = [
        "<tr>",
        f"<{cell_text}>{'<strong>' if have_strong_head else ''}{head}{'<strong>' if have_strong_head else ''}</{cell_text}>",
        f"<{cell_text}>{'<strong>' if have_strong_value else ''}{value}{'<strong>' if have_strong_value else ''}</{cell_text}>",
        "</tr>"
    ]
    return "".join([f"{x}\n" for x in lines])

total_hack_data = []
for hack in [x for x in os.listdir("./hack-data") if x != "info.json"]:
    hack_data = None
    with open(f"./hack-data/{hack}/data.json", "r") as fh:
        hack_data = json.load(fh)
    if len(hack_data.get("images", [])) == 0:
        raise Exception("No images listed, cannot parse")
    total_hack_data.append(
        {
            "hack_short": hack,
            "hack_name": hack_data["name"],
            "image": fileRefToURL(hack_data["images"][0], hack),
            "description": hack_data.get("short_description", "")
        }
    )
    with open("hack-page-template.html", "r") as template:
        with open(f"{hack}.html", "w") as page:
            page.write("<!-- DO NOT EDIT THIS FILE MANUALLY. CHANGE THE HACK TEMPLATE INSTEAD -->\n")
            lines = template.readlines()
            for line in lines:
                if "property=\"og:title\" />" in line:
                    page.write(line.replace("content=\"Site Page\"", f"content=\"{hack_data['name']}\""))
                elif "<li class=\"breadcrumb-item active\" aria-current=\"page\">" in line:
                    page.write(f"<li class=\"breadcrumb-item active\" aria-current=\"page\">{hack_data['name']}</li>\n")
                elif "<title>" in line:
                    page.write(f"\t\t<title>{hack_data['name']}</title>\n")
                elif "<h2>Hack Name</h2>" in line:
                    page.write(f"<h2>{hack_data['name']}</h2>\n")
                elif "<div id=\"hack-description\"></div>" in line:
                    page.write(f"<div id=\"hack-description\" class=\"mb-3\">{hack_data['description']}</div>\n")
                    # Image Parsing
                    if len(hack_data.get("images", [])) > 1:
                        page.write("<h3>Images</h3>\n")
                        page.write("<div class=\"d-flex flex-wrap mb-3\">\n")
                        for index, img in enumerate(hack_data["images"][1:]):
                            page.write(f"<img src=\"{fileRefToURL(img, hack)}\" width=\"200px\" class=\"pe-2 pb-2\" alt=\"{img}\" data-bs-toggle=\"modal\" data-bs-target=\"#imageModal{index}\">\n")
                            page.write(f"<div class=\"modal fade\" id=\"imageModal{index}\" tabindex=\"-1\" aria-labelledby=\"imageModal{index}Label\" aria-hidden=\"true\">\n")
                            page.write("<div class=\"modal-dialog modal-lg\">\n")
                            page.write("<div class=\"modal-content\">\n")
                            page.write("<div class=\"modal-header\">\n")
                            page.write("<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"modal\" aria-label=\"Close\"></button>\n")
                            page.write("</div>\n")
                            page.write("<div class=\"modal-body\">\n")
                            page.write("<div class=\"d-flex\">\n")
                            page.write(f"<img src=\"{fileRefToURL(img, hack)}\" style=\"margin-left:auto;margin-right:auto;max-width:100%\" alt=\"{img}\">\n")
                            page.write("</div>\n")
                            page.write("</div>\n")
                            page.write("</div>\n")
                            page.write("</div>\n")
                            page.write("</div>\n")
                        page.write("</div>")
                    # Credit Parsing
                    if len(hack_data.get("other_credits", [])) > 0:
                        page.write("<h3>Credits</h3>\n")
                        page.write("<table class=\"table table-striped table-hover\">\n")
                        page.write("<thead>\n")
                        page.write(getHackInfoHTML("User", "Contribution", True, True))
                        page.write("</thead>\n")
                        page.write("<tbody>\n")
                        for credit in hack_data["other_credits"]:
                            page.write(getHackInfoHTML(credit["user"], credit["credit"], False))
                        page.write("</tbody>\n")
                        page.write("</table>\n")
                elif "<img src=\"\" id=\"main-image\">" in line:
                    images = hack_data.get("images", [])
                    chosen_image = "./assets/logo.png"
                    if len(images) > 0:
                        chosen_image = images[0]
                    page.write(f"<img src=\"{fileRefToURL(chosen_image, hack)}\" id=\"main-image\">\n")
                elif "<table id=\"hack-info\"></table>" in line:
                    page.write("<table id=\"hack-info\" class=\"table table-striped\">\n")
                    # Developers
                    dev_head = "Developers"
                    if len(hack_data['developers']) == 1 and hack_data['developers'][0] != "Many": 
                        dev_head = "Developer"
                    page.write(getHackInfoHTML(dev_head, ', '.join(hack_data['developers'])))
                    # Hack Type
                    page.write(getHackInfoHTML("Type", hack_data.get("hack_type", "not provided").title()))
                    # URL
                    if "github" in hack_data:
                        page.write(getHackInfoHTML("Source Code", f"<a href=\"{hack_data['github']}\">Link</a>"))
                    # Tag Anywhere
                    page.write(getHackInfoHTML("Tag Anywhere", "Enabled" if hack_data.get("tag_anywhere", False) else "Disabled"))
                    # Download
                    if hack == "randomizer":
                        # For now, always link to the stable version
                        primary_download = "https://dk64randomizer.com/randomizer.html"
                    else:
                        primary_version = list(hack_data['downloads'])[0]
                        primary_download = fileRefToURL(hack_data['downloads'][primary_version], hack)
                    page.write(getHackInfoHTML("Download", f"<a href=\"{primary_download}\">Link</a>"))
                    # End
                    page.write("</table>\n")
                else:
                    page.write(line)
with open("./hack-data/info.json", "w") as fh:
    fh.write(json.dumps(total_hack_data, indent=4))
