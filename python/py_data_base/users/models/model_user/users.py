from python.py_data_base.users.base import Base
from sqlalchemy.orm import Mapped, mapped_column


class Users(Base):
    id: Mapped[int] = mapped_column(primary_key=True)
    last_name: Mapped[str]
    first_name: Mapped[str]
    second_name: Mapped[str]
    tab_number: Mapped[int]
    position_users: Mapped[str]
    login: Mapped[str]
    password: Mapped[str]
    day_registration: Mapped[str]
    access_group: Mapped[str]

    def __repr__(self) -> str:
        return (f'{self.id} {self.last_name} {self.first_name} {self.second_name} {self.tab_number} {self.position_users} {self.login} {self.password} {self.day_registration} {self.access_group}')
