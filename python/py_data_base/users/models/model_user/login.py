from python.py_data_base.users.base import Base
from sqlalchemy.orm import Mapped, mapped_column


class LogIn(Base):
    id: Mapped[int] = mapped_column(primary_key=True)
    day_in: Mapped[str]
    family: Mapped[str]
    first_name: Mapped[str]
    second_name: Mapped[str]
    tab_number: Mapped[int]
    position_users: Mapped[str]

    def __repr__(self) -> str:
        return (f'{self.id} {self.daty_registration} {self.family} {self.first_name} {self.second_name} {self.tab_number} {self.position_users}')
