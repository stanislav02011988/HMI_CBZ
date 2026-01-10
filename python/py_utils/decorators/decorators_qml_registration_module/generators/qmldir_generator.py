# This Python file uses the following encoding: utf-8


class QmldirGenerator:
    def __init__(self, module_name: str, qmldir_path, qmltypes_path):
        self.module_name = module_name
        self.qmldir_path = qmldir_path
        self.qmltypes_filename = qmltypes_path.name

    def generate(self):
        content = (
            f"module {self.module_name}\n"
            f"typeinfo {self.qmltypes_filename}\n"
        )

        if self.qmldir_path.exists():
            current = self.qmldir_path.read_text(encoding="utf-8").strip()
            if current == content.strip():
                return  # ничего не изменилось

        self.qmldir_path.write_text(content, encoding="utf-8")
        print(f"[QmlModuleInterface] Обновлён qmldir:\n{content}")
