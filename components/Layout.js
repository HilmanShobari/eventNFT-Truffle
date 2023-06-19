import React from "react";
import "semantic-ui-css/semantic.min.css";
import { Container } from "semantic-ui-react";

const Layout = (props) => {
    return (
        <Container>
            {props.children}
        </Container>
    );
};

export default Layout;