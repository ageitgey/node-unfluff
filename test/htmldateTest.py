
import json
from pprint import pprint
from htmldate import find_date
from lxml import html

def getDate(htmldoc):
    mytree = html.fromstring(htmldoc)

    return find_date(mytree, outputformat='%Y-%m-%d %H:%M')


def jsDateToPython():
    with open('withDate.json', 'r') as f, open('find_date_withDate.json', 'w') as j:
        distros_dict = json.load(f)
        pprint(distros_dict)
        new_dict_list = []
        for el in distros_dict:
            new_dict_list.append({
                'pythonfound': find_date(el['url']),
                **el
            })
        pprint(new_dict_list)
        json.dump(new_dict_list, j)

if __name__ == "__main__":
    # execute only if run as a script
    htmldoc = '<html><body><span class="entry-date">17:32:14 July 12th, 2016</span></body></html>'
    getDate(htmldoc)

    # print(find_date(mytree, original_date=True))
    # # print(find_date(mytree, outputformat='%d %B %Y'))
    # print(find_date(mytree, outputformat='%Y-%m-%d %H:%M'))