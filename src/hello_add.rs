fn add(x:i8, y:i8) -> i8 {
    let a = x + y;
    a + a
}

fn main() {
    let x = 1;
    let y = 2;
    let z = add(x, y);
    println!("Hello {x} + {y} = {z} \n");
}
