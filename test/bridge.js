//@flow
import pythonBridge from 'python-bridge';

class PythonAdapter {
    _py: pythonBridge.PythonBridge;
    constructor() {
        this._py = pythonBridge({
            python: 'python3',
       //.     env: {PYTHONPATH: '/foo/bar'} 
        });

        this._py.ex`
            from htmldate import find_date
            from lxml import html

            def getDate(htmldoc):
                mytree = html.fromstring(htmldoc)

                return find_date(mytree, outputformat='%Y-%m-%d %H:%M')
        `
    }

    async testFun(a,b) {
        let tmp = this._py.ex
        this._py.ex`
            def add(a, b):
                return a + b
        `
        let test = this._py`add(${a},${b})`
        this._py.ex = tmp
        return test
    }

    async find_date(htmldoc) {
        return this._py`getDate(${htmldoc})`
    }

}
export default PythonAdapter;