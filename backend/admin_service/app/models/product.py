from pydantic import BaseModel


class ProductCreate(BaseModel):
    name: str
    category: str | None = None
    cost: float = 0.0
    discount_pct: int = 0
    rating: float = 0.0
    ecom: str | None = None
    ecom_logo: str | None = None
    image_url: str | None = None
    website_url: str | None = None
    in_stock: bool = True


class ProductUpdate(BaseModel):
    name: str | None = None
    category: str | None = None
    cost: float | None = None
    discount_pct: int | None = None
    rating: float | None = None
    ecom: str | None = None
    image_url: str | None = None
    website_url: str | None = None
    in_stock: bool | None = None


class ProductOut(BaseModel):
    id: int
    name: str
    category: str | None
    cost: float
    discount_pct: int
    rating: float
    ecom: str | None
    ecom_logo: str | None
    image_url: str | None
    website_url: str | None
    in_stock: bool
